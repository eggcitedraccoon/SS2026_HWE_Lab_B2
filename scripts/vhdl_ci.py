#!/usr/bin/env python3
"""
VHDL CI Script
==============
Analyzes and simulates all VHDL files found under labs/.

Phases:
  1. Analyze all source (.vhd) files — with retry to resolve dependency order
  2. Analyze all testbench files — same retry strategy
  3. Elaborate + run each testbench that compiled successfully
  4. Write TEST_RESULTS.md with a full Markdown table

Exit code: 0 if everything passes, 1 if any compile or sim failure.

Testbench naming convention (case-insensitive):
  *_tb.vhd   tb_*.vhd   *testbench*.vhd

Simulation termination:
  GHDL stops naturally if the testbench calls std.env.stop (VHDL-2008, exit 0).
  If your testbench uses "assert false severity failure" as a stop signal, the
  script will still mark it as PASS provided no other failure-level messages
  appear before that final assertion.
  Simulations that do not self-terminate are cut off after STOP_TIME (default 1 ms).
"""

import re
import subprocess
import sys
from datetime import datetime, timezone
from pathlib import Path

# ── Configuration ──────────────────────────────────────────────────────────────
VHDL_STD   = "08"          # VHDL standard: 93 | 08
STOP_TIME  = "1ms"         # Hard wall-clock cut-off for non-terminating sims
WORK_DIR   = Path("ghdl_work")
RESULTS_MD = Path("TEST_RESULTS.md")
LABS_ROOT  = "labs"
MAX_PASSES = 15            # Retry ceiling for dependency-order resolution
SIM_TIMEOUT_S = 60         # subprocess timeout in seconds

# Patterns that indicate an intentional "end of simulation" assertion failure.
# GHDL exits 1 for ANY severity-failure assertion; these are benign stop signals.
_END_OF_SIM_RE = re.compile(
    r"(simulation\s+finished|sim\s+(done|complete|ended)|"
    r"all\s+tests?\s+pass(ed)?|end\s+of\s+(sim(ulation)?|test)|"
    r"test(s)?\s+(complete|done|finished|pass(ed)?))",
    re.IGNORECASE,
)

# ── Helpers ────────────────────────────────────────────────────────────────────

def find_vhd_files(root: str = LABS_ROOT) -> list[Path]:
    return sorted(Path(root).rglob("*.vhd"))


def is_testbench(path: Path) -> bool:
    stem = path.stem.lower()
    return (
            stem.endswith("_tb")
            or stem.startswith("tb_")
            or "testbench" in stem
    )


def extract_entity(path: Path) -> str | None:
    """Parse the first 'entity NAME is' declaration from a VHDL file."""
    try:
        text = path.read_text(errors="ignore")
    except OSError:
        return None
    m = re.search(r"^\s*entity\s+(\w+)\s+is", text, re.IGNORECASE | re.MULTILINE)
    return m.group(1) if m else None


def ghdl(*args) -> tuple[bool, str]:
    """Run a ghdl command; returns (success, stderr_text)."""
    cmd = ["ghdl", *args]
    result = subprocess.run(cmd, capture_output=True, text=True)
    return result.returncode == 0, result.stderr.strip()


def ghdl_analyze(path: Path) -> tuple[bool, str]:
    return ghdl("-a", f"--std={VHDL_STD}", f"--workdir={WORK_DIR}", str(path))


def ghdl_elaborate(entity: str) -> tuple[bool, str]:
    return ghdl("-e", f"--std={VHDL_STD}", f"--workdir={WORK_DIR}", entity)


def ghdl_run(entity: str) -> tuple[bool, str]:
    """
    Run a simulation.  Returns (pass, stderr).

    GHDL exit codes:
      0  – clean finish (std.env.stop / std.env.finish, or --stop-time triggered)
      1  – assertion failure (may be intentional stop signal OR real error)

    We disambiguate exit-1 by checking whether every failure-level line in
    stderr looks like a known end-of-simulation marker.
    """
    try:
        result = subprocess.run(
            [
                "ghdl", "-r",
                f"--std={VHDL_STD}",
                f"--workdir={WORK_DIR}",
                entity,
                f"--stop-time={STOP_TIME}",
            ],
            capture_output=True,
            text=True,
            timeout=SIM_TIMEOUT_S,
        )
    except subprocess.TimeoutExpired:
        return False, f"Simulation timed out after {SIM_TIMEOUT_S} s"

    stderr = result.stderr.strip()

    if result.returncode == 0:
        return True, stderr

    # Exit 1: check whether it's only a benign stop-signal assertion
    failure_lines = [
        ln for ln in stderr.splitlines()
        if re.search(r"\b(failure|error)\b", ln, re.IGNORECASE)
    ]
    if failure_lines and all(_END_OF_SIM_RE.search(ln) for ln in failure_lines):
        return True, stderr   # Intentional stop — treat as pass

    return False, stderr


# ── Analysis with retry ────────────────────────────────────────────────────────

def analyze_with_retry(files: list[Path]) -> tuple[list[Path], list[Path], dict[Path, str]]:
    """
    Analyze files in multiple passes to handle arbitrary dependency order.

    Returns:
        passed  – files that compiled successfully
        failed  – files that never compiled
        errors  – last error message per failed file
    """
    remaining: set[Path] = set(files)
    passed: list[Path] = []
    errors: dict[Path, str] = {}

    for pass_num in range(1, MAX_PASSES + 1):
        if not remaining:
            break
        progress = False
        still_failing: set[Path] = set()

        for path in sorted(remaining):
            ok, err = ghdl_analyze(path)
            if ok:
                passed.append(path)
                errors.pop(path, None)
                progress = True
            else:
                still_failing.add(path)
                errors[path] = err

        remaining = still_failing
        if not progress:
            # No new files compiled — circular dependency or genuine errors
            break

    return passed, sorted(remaining), errors


# ── Markdown generation ────────────────────────────────────────────────────────

STATUS_ICON = {
    "pass":    "✅ Pass",
    "fail":    "❌ Fail",
    "timeout": "⏱️ Timeout",
    "skip":    "⚠️ Skipped",
}


def build_markdown(
        all_files: list[Path],
        src_passed: list[Path],
        src_failed: list[Path],
        tb_passed: list[Path],
        tb_failed: list[Path],
        sim_results: list[tuple],   # (path, entity, status, notes)
) -> str:
    now = datetime.now(timezone('Europe/Berlin')).strftime("%Y-%m-%d %H:%M CET")

    compile_total  = len(all_files)
    compile_passed = len(src_passed) + len(tb_passed)
    sim_pass_count = sum(1 for *_, s, __ in sim_results if s == "pass")
    sim_total      = len(sim_results)

    compile_emoji = "✅" if compile_passed == compile_total else "❌"
    sim_emoji     = "✅" if (sim_total == 0 or sim_pass_count == sim_total) else "❌"

    lines = [
        "# VHDL CI — Test Results",
        "",
        f"**Last run:** {now} &nbsp;|&nbsp; **Standard:** VHDL-{VHDL_STD} &nbsp;|&nbsp; "
        f"**Simulator:** GHDL",
        "",
        "## Summary",
        "",
        f"| Check | Result |",
        f"|-------|--------|",
        f"| Compilation | {compile_emoji} {compile_passed}/{compile_total} files |",
        f"| Simulation  | {sim_emoji} {sim_pass_count}/{sim_total} testbenches |",
        "",
        "## Compilation",
        "",
        "| File | Type | Status |",
        "|------|------|--------|",
    ]

    all_compile = sorted(
        [(p, "Source",    "✅ Pass") for p in src_passed] +
        [(p, "Testbench", "✅ Pass") for p in tb_passed] +
        [(p, "Source",    "❌ Fail") for p in src_failed] +
        [(p, "Testbench", "❌ Fail") for p in tb_failed],
        key=lambda t: t[0],
        )
    for path, kind, status in all_compile:
        lines.append(f"| `{path}` | {kind} | {status} |")

    if sim_results:
        lines += [
            "",
            "## Simulation",
            "",
            "| Testbench | Entity | Status | Notes |",
            "|-----------|--------|--------|-------|",
        ]
        for path, entity, status, notes in sim_results:
            icon      = STATUS_ICON.get(status, status)
            entity_md = f"`{entity}`" if entity else "—"
            note_md   = (notes or "").replace("\n", " ").strip()[:120]
            lines.append(f"| `{path}` | {entity_md} | {icon} | {note_md} |")

    lines += [
        "",
        "---",
        "_This file is auto-generated by the VHDL CI workflow. Do not edit manually._",
    ]

    return "\n".join(lines) + "\n"


# ── Main ───────────────────────────────────────────────────────────────────────

def section(title: str):
    print(f"\n{'─' * 60}")
    print(f"  {title}")
    print(f"{'─' * 60}")


def main() -> int:
    WORK_DIR.mkdir(exist_ok=True)

    all_files  = find_vhd_files()
    src_files  = [f for f in all_files if not is_testbench(f)]
    tb_files   = [f for f in all_files if     is_testbench(f)]

    print(f"\n🔍 Discovered {len(src_files)} source file(s) "
          f"and {len(tb_files)} testbench file(s) under '{LABS_ROOT}/'")

    # ── Phase 1: Source files ──────────────────────────────────────────────────
    section("Phase 1 — Analyzing source files")
    src_passed, src_failed, src_errors = analyze_with_retry(src_files)

    for f in src_passed:
        print(f"  ✅  {f}")
    for f in src_failed:
        print(f"  ❌  {f}")
        for line in src_errors[f].splitlines()[:5]:
            print(f"       {line}")

    # ── Phase 2: Testbenches ───────────────────────────────────────────────────
    section("Phase 2 — Analyzing testbenches")
    tb_passed, tb_failed, tb_errors = analyze_with_retry(tb_files)

    for f in tb_passed:
        print(f"  ✅  {f}")
    for f in tb_failed:
        print(f"  ❌  {f}")
        for line in tb_errors[f].splitlines()[:5]:
            print(f"       {line}")

    # ── Phase 3: Simulation ────────────────────────────────────────────────────
    section("Phase 3 — Running simulations")
    sim_results: list[tuple] = []

    for tb in tb_passed:
        entity = extract_entity(tb)
        if not entity:
            print(f"  ⚠️   {tb}  — could not extract entity name, skipping")
            sim_results.append((tb, None, "skip", "Could not parse entity name"))
            continue

        elab_ok, elab_err = ghdl_elaborate(entity)
        if not elab_ok:
            print(f"  ❌  {tb}  [{entity}] — elaboration failed")
            for line in elab_err.splitlines()[:5]:
                print(f"       {line}")
            sim_results.append((tb, entity, "fail", elab_err))
            continue

        run_ok, run_out = ghdl_run(entity)
        icon   = "✅" if run_ok else "❌"
        status = "pass" if run_ok else "fail"
        print(f"  {icon}  {tb}  [{entity}]")
        if not run_ok and run_out:
            for line in run_out.splitlines()[:5]:
                print(f"       {line}")
        sim_results.append((tb, entity, status, run_out))

    # ── Results ────────────────────────────────────────────────────────────────
    section("Summary")

    compile_passed = len(src_passed) + len(tb_passed)
    compile_total  = len(all_files)
    sim_pass_count = sum(1 for *_, s, __ in sim_results if s == "pass")
    sim_total      = len(sim_results)

    print(f"  Compilation : {compile_passed}/{compile_total} files OK")
    print(f"  Simulation  : {sim_pass_count}/{sim_total} testbenches passed")

    md = build_markdown(
        all_files, src_passed, src_failed, tb_passed, tb_failed, sim_results
    )
    RESULTS_MD.write_text(md)
    print(f"\n  📄  Results written to {RESULTS_MD}")

    overall_ok = (
            len(src_failed) == 0
            and len(tb_failed) == 0
            and (sim_total == 0 or sim_pass_count == sim_total)
    )

    if overall_ok:
        print("\n  ✅  CI PASSED\n")
        return 0
    else:
        print("\n  ❌  CI FAILED\n")
        return 1


if __name__ == "__main__":
    sys.exit(main())
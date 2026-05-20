# Hardware Engineering SS26 Team B2

![VHDL Compile & Simulate](https://github.com/eggcitedraccoon/SS2026_HWE_Lab_B2/actions/workflows/vhdl-ci.yml/badge.svg)
![Compile LaTeX](https://github.com/eggcitedraccoon/SS2026_HWE_Lab_B2/actions/workflows/compile-latex.yml/badge.svg)

📋 [Latest VHDL test results](TEST_RESULTS.md)
📑 [Seminar Paper](seminar/main.pdf)

## Distribution of tasks
### Labs
| №      | Task | Short summary | Responsible person | Deadline | Status |
|:-------|:-----|:--------------|:-------------------|:---------|:-------|
| **1**  |      |               |                    |          |        |
| **2**  |      |               |                    |          |        |
| **3**  |      |               |                    |          |        |
| **4**  |      |               |                    |          |        |
### Project
| №      | Task | Short summary | Responsible person | Deadline | Status |
|:-------|:-----|:--------------|:-------------------|:---------|:-------|
| **1**  |      |               |                    |          |        |
| **2**  |      |               |                    |          |        |
| **3**  |      |               |                    |          |        |
| **4**  |      |               |                    |          |        |
### Seminar
| №     | Task                   | Responsible person                                 | Deadline   | Status           |
|:------|:-----------------------|:---------------------------------------------------|:-----------|:-----------------|
| **1** | Overview               | [Petr Lavrenov](https://github.com/DustyPetrol)    | 31.05.2026 | 📝 *In progress* |
| **2** | Industrial application | [Oleg Kelner](https://github.com/eggcitedraccoon)  | 31.05.2026 | 📝 *In progress* |
| **3** | Home application       | [Hany Chowdhury](https://github.com/HanyChowdhury) | 31.05.2026 | 📝 *In progress* |
| **4** | Industrial standarts   | [John Abah](https://github.com/john-abah)          | 31.05.2026 | 📝 *In progress* |
| **5** | Introduction           |                                                    | 05.06.2026 |                  |
| **6** | Conclusion             |                                                    | 05.06.2026 |                  |
| **7** | Abstract and keywords  |                                                    | 05.06.2026 |                  |


## Repo structure
### Labs
```
labs/
├— lab01/
│   ├— ANDGATTER.vhd
│   ├— ORGATTER.vhd
│   └─ ...
│
├— lab02/
│   ├— ex01/
│   │   ├— src/
│   │   │  └— ...
│   │   │
│   │   ├— tb/
│   │   │  └— ...
│   │   └— ...
│   │
│   ├— ex02/
│   │   └ ...
│   └ ...
└ ...
```
### Project
```
project/
├— report/
│   ├— report.pdf
│   ├— report.tex
│   ├— intro.tex
│   └─ ...
│
├— src/
│   ├— module.vhd
│   └— ...
└— tb/
    ├— module_tb.vhd
    └— ...
```
### Seminar
```
seminar/
├— main.pdf
├— main.tex
├— intro.tex
└─ ...

```
### Other
In directories `scripts` and `.github` there are auxilary files, such as automatic VHDL compiler, etc.

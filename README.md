# Hardware Engineering SS26 Team B2

| Tests                                                                                                                    | Results                                        |
|--------------------------------------------------------------------------------------------------------------------------|------------------------------------------------|
| ![VHDL Compile & Simulate](https://github.com/eggcitedraccoon/SS2026_HWE_Lab_B2/actions/workflows/vhdl-ci.yml/badge.svg) | 📋 [Latest VHDL test results](TEST_RESULTS.md) |
| ![Compile LaTeX](https://github.com/eggcitedraccoon/SS2026_HWE_Lab_B2/actions/workflows/compile-latex.yml/badge.svg)     | 📑 [Seminar Paper](seminar/main.pdf)           |


## Distribution of tasks

### Labs

| №     | Task             | Short summary      | Responsible person                                                                                  | Deadline | Status |
|:------|:-----------------|:-------------------|:----------------------------------------------------------------------------------------------------|:---------|:-------|
| **1** | Lab 1            | Basic Logic        | [Oleg Kelner](https://github.com/eggcitedraccoon)                                                   | na       | Done   |
| **2** | Lab 2 Task 1–3   | Combinatory logic  | [Oleg Kelner](https://github.com/eggcitedraccoon) / [Petr Lavrenov](https://github.com/DustyPetrol) | na       | Done   |
| **3** | Lab 2 Task 4–5   | Combinatory logic  | [Hany Chowdhury](https://github.com/HanyChowdhury)                                                  |          |        |
| **4** | Lab 3 and 4      | Altium             | [Hany Chowdhury](https://github.com/HanyChowdhury)                                                  |          |        |
| **5** | Lab 6            |                    |                                                                                                     |          |        |
### Project
| №      | Task | Short summary | Responsible person | Deadline | Status |
|:-------|:-----|:--------------|:-------------------|:---------|:-------|
| **1**  |      |               |                    |          |        |
| **2**  |      |               |                    |          |        |
| **3**  |      |               |                    |          |        |
| **4**  |      |               |                    |          |        |
### Seminar
| №     | Task                    | Responsible person                                                                               | Deadline   | Status            |
|:------|:------------------------|:-------------------------------------------------------------------------------------------------|:-----------|:------------------|
| **1** | References              | Everyone have to add their references to the `references.bib`                                    | 24.05.2026 | 📝 *In progress*  |
| **2** | Overview                | [Petr Lavrenov](https://github.com/DustyPetrol)                                                  | 31.05.2026 | 📝 *In progress*  |
| **3** | Industrial application  | [Oleg Kelner](https://github.com/eggcitedraccoon)                                                | 31.05.2026 | 📝 *In progress*  |
| **4** | Home application        | [Hany Chowdhury](https://github.com/HanyChowdhury)                                               | 31.05.2026 | 📝 *In progress*  |
| **5** | Industrial standarts    | [John Abah](https://github.com/john-abah)                                                        | 31.05.2026 | 📝 *In progress*  |
| **6** | Presentation Pictures   | Everyone have to add their Pictures to the `presentation` folder along with resources and a presentation plan | 08.06.2026 |                   |
| **7** | Abstract and keywords   |                                                                                                  | 08.06.2026 |                   |
| **8** | Conclusion              |                                                                                                  | 08.06.2026 |                   |


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
├— references.bib
└— src/
    ├— 00_abstract.tex
    ├— 01_overview.tex
    └— ...

```
### Other
In directories `scripts` and `.github` there are auxilary files, such as automatic VHDL compiler, etc.

# Hardware Engineering SS26 Team B2

| Tests                                                                                                                    | Results                                        |
|--------------------------------------------------------------------------------------------------------------------------|------------------------------------------------|
| ![VHDL Compile & Simulate](https://github.com/eggcitedraccoon/SS2026_HWE_Lab_B2/actions/workflows/vhdl-ci.yml/badge.svg) | 📋 [Latest VHDL test results](TEST_RESULTS.md) |
| ![Compile LaTeX](https://github.com/eggcitedraccoon/SS2026_HWE_Lab_B2/actions/workflows/compile-latex.yml/badge.svg)     | 📑 [Seminar Paper](seminar/main.pdf)           |


## Distribution of tasks

### Labs

| №     | Task             | Short summary      | Responsible person                                                                                  |  Status |
|:------|:-----------------|:-------------------|:----------------------------------------------------------------------------------------------------|:-------:|
| **1** | Lab 1            | Basic Logic        | [Oleg Kelner](https://github.com/eggcitedraccoon)                                                   | ✅ *Done*   |
| **2** | Lab 2 Task 1–3   | Combinatory logic  | [Oleg Kelner](https://github.com/eggcitedraccoon) / [Petr Lavrenov](https://github.com/DustyPetrol) | ✅ *Done*  |
| **3** | Lab 2 Task 4–5   | Combinatory logic  | [Hany Chowdhury](https://github.com/HanyChowdhury) |:arrows_counterclockwise: *In progress*        |
| **4** | Lab 3 and 4      | Altium             | [Hany Chowdhury](https://github.com/HanyChowdhury) | :arrows_counterclockwise: *In progress*       |
| **5** | Lab 5            | Vivado and Nexys A7| [Oleg Kelner](https://github.com/eggcitedraccoon)  |            ✅ *Done*      |
| **6** | Lab 7            | Clocks             | [Oleg Kelner](https://github.com/eggcitedraccoon)  |            :arrows_counterclockwise: *In progress*      |

### Project
| №      | Task | Short summary | Responsible person | Status |
|:-------|:-----|:--------------|:-------------------|:-------|
| **1**  |Colour change|               |[Petr Lavrenov](https://github.com/DustyPetrol) |Done    |
| **2**  |Fade module|               |[Oleg Kelner](https://github.com/eggcitedraccoon)  |Done    |
| **3**  |Blink Module|               |[Hany Chowdhury](https://github.com/HanyChowdhury)|Done    |
| **4**  |Altium |               |[Hany Chowdhury](https://github.com/HanyChowdhury)|Done    |
| **5**  |Top Level module |               |[Oleg Kelner](https://github.com/eggcitedraccoon) |Done    |
| **6**  |PWM generator |               |[Petr Lavrenov](https://github.com/DustyPetrol)|Done    |

### Seminar
| №     | Task                    | Responsible person                                                                               | Deadline   | Status            |
|:------|:------------------------|:-------------------------------------------------------------------------------------------------|:-----------|:------------------:|
| **1** | References              | Everyone have to add their references to the `references.bib`                                    | 24.05.2026 | ✅ *Done*  |
| **2** | Overview                | [Petr Lavrenov](https://github.com/DustyPetrol)                                                  | 31.05.2026 | ✅ *Done*  |
| **3** | Industrial application  | [Oleg Kelner](https://github.com/eggcitedraccoon)                                                | 31.05.2026 | ✅ *Done*  |
| **4** | Home application        | [Hany Chowdhury](https://github.com/HanyChowdhury)                                               | 31.05.2026 | ✅ *Done*  |
| **6** | Presentation Pictures   | Everyone have to add their Pictures to the `presentation` folder along with resources and a presentation plan | 08.06.2026 |✅ *Done*      |
| **7** | Abstract and keywords   | [Petr Lavrenov](https://github.com/DustyPetrol)                 | 14.06.2026 |  ✅ *Done*                 |
| **8** | Conclusion              | [Oleg Kelner](https://github.com/eggcitedraccoon)                                                 | 14.06.2026 |    ✅ *Done*               |


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
#### Paper
```
seminar/
├— main.pdf
├— main.tex
├— references.bib
├— assets/
│   ├— slide1-1.png
│   ├— slide1-2.jpg
│   └— ...
└— src/
    ├— 00_abstract.tex
    ├— 01_overview.tex
    └— ...
```
#### Presentation
```
Presentation/
├— Power_Line_Communication.pdf
├— Power_Line_Communication.pptx
└— ...
```
### Other
In directories `scripts` and `.github` there are auxilary files, such as automatic VHDL compiler, etc.

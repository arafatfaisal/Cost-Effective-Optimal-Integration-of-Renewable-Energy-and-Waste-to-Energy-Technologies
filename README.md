# Cost-Effective-Optimal-Integration-of-Renewable-Energy-and-Waste-to-Energy-Technologies
# Cost-Effective Optimal Integration of Renewable Energy and Waste-to-Energy Technologies

**A MATLAB-Based Optimization Framework for Hybrid Renewable Energy Microgrids**

[![Publication](https://img.shields.io/badge/Publication-Journal%20of%20Engineering-blue)](https://doi.org/10.1049/tje2.70148)
[![DOI](https://img.shields.io/badge/DOI-10.1049%2Ftje2.70148-green)](https://doi.org/10.1049/tje2.70148)
[![Language](https://img.shields.io/badge/Language-MATLAB-orange)](https://www.mathworks.com/products/matlab.html)
[![Status](https://img.shields.io/badge/Research-Published-success)](https://doi.org/10.1049/tje2.70148)

## Overview

This repository contains the MATLAB implementation, input datasets, simulation results, and visualization outputs of the research project **"Cost-Effective Optimal Integration of Renewable Energy and Waste-to-Energy Technologies."**

The project investigates the optimal integration and sizing of renewable energy resources and waste-to-energy (WtE) technologies in a hybrid microgrid system. The primary objective is to develop a cost-effective and environmentally sustainable energy management framework while maintaining reliable electricity supply.

The proposed system integrates solar photovoltaic (PV), wind turbines (WT), FastOx-based waste-to-energy technology, diesel generators (DG), and battery energy storage. Metaheuristic optimization algorithms, particularly Particle Swarm Optimization (PSO) and Grey Wolf Optimization (GWO), are implemented to determine optimal system configurations and minimize the Levelized Cost of Energy (LCoE).

The research uses real-world meteorological data and municipal solid waste profiles from **Halishahar, Bangladesh**, demonstrating the potential of integrated renewable energy and waste-to-energy systems in developing regions.

This repository serves as the computational companion to the published journal article, providing the MATLAB codes, datasets, and generated outputs associated with the research.

## Published Research

This research has been published in *The Journal of Engineering* (IET/Wiley).

**Paper Title:** Cost-Effective Optimal Integration of Renewable Energy and Waste-to-Energy Technologies

**Authors:** Md Sajjad-Ul Islam, Md. Arafat Bin Zafar, Md. Rashidul Islam, Arafat Ibne Ikram, and Md Shafiullah.

**Journal:** The Journal of Engineering, 2025

**DOI:** [10.1049/tje2.70148](https://doi.org/10.1049/tje2.70148)

**Full Article:** [Read the published research paper](https://ietresearch.onlinelibrary.wiley.com/doi/10.1049/tje2.70148)

## Research Objectives

The main objectives of this research are:

- Develop an integrated hybrid microgrid incorporating renewable energy and waste-to-energy technologies.
- Optimize the sizing and integration of different energy generation and storage components.
- Implement PSO and GWO metaheuristic optimization algorithms.
- Minimize the Levelized Cost of Energy (LCoE) and improve the economic feasibility of the proposed system.
- Evaluate system performance through technical, economic, and environmental analyses.
- Compare the optimization results against the HOMER simulation platform.

## Hybrid Microgrid Architecture

The proposed hybrid energy system consists of the following components:

| Component | Description |
|---|---|
| Solar PV | Electricity generation from solar energy |
| Wind Turbine (WT) | Electricity generation from wind resources |
| Waste-to-Energy (WtE) | Electricity generation using municipal solid waste through FastOx gasification |
| Diesel Generator (DG) | Backup electricity generation |
| Battery Energy Storage | Energy storage and discharge management |
| Power Converters | AC/DC power conversion and system integration |

The system combines renewable energy generation, waste utilization, and energy storage to provide a reliable and economically optimized electricity supply.

## Optimization Methodology

Two metaheuristic optimization algorithms are implemented and evaluated:

**1. Particle Swarm Optimization (PSO)**

PSO is employed to identify an optimal configuration of the hybrid microgrid components by iteratively updating candidate solutions based on individual and collective search experiences.

**2. Grey Wolf Optimization (GWO)**

GWO is implemented as an alternative optimization technique inspired by the leadership hierarchy and hunting behavior of grey wolves. It is used to search for an economically optimal system configuration.

**3. HOMER Benchmarking**

The optimization outcomes are compared with HOMER-based simulation results to evaluate the economic performance of the proposed approaches.

## Key Research Findings

The optimization framework demonstrates improved economic performance compared with the benchmark simulation.

| Optimization Method | LCoE ($/kWh) |
|---|---:|
| Grey Wolf Optimization (GWO) | **0.221** |
| Particle Swarm Optimization (PSO) | 0.223 |
| HOMER | 0.468 |

**Key observations:**

- GWO achieved the lowest LCoE among the evaluated approaches.
- PSO also demonstrated competitive economic performance.
- The integration of waste-to-energy technology improved energy diversity and contributed to emission reduction.
- The proposed optimization framework demonstrated the potential for economically viable hybrid microgrids.

*Note: These values represent the reported findings of the published research paper.*

## Repository Contents

This repository contains the following research materials:

| Category | Contents |
|---|---|
| Input Data | Dataset and data sheets used in the simulation |
| Main MATLAB Program | Main simulation and optimization execution file |
| PSO Implementation | MATLAB implementation of Particle Swarm Optimization |
| Charging Model | Battery charging management and associated calculations |
| Discharging Model | Battery discharging management and associated calculations |
| Economic Cost | Economic cost calculation routines |
| Economic Analysis | Financial and economic feasibility evaluation |
| NPC Calculation | Net Present Cost (NPC) calculation |
| Plot Statistics | Statistical analysis and visualization routines |
| Generated Outputs | Simulation results, graphs, and other output files |

The repository includes the MATLAB source files and associated supporting materials used throughout the research.

## Technologies and Tools

- **MATLAB:** Mathematical modeling, simulation, and algorithm implementation.
- **Particle Swarm Optimization:** Metaheuristic optimization.
- **Grey Wolf Optimization:** Metaheuristic optimization.
- **HOMER:** Benchmarking and comparative simulation.
- **Data Visualization:** Graphical representation and statistical analysis of simulation results.

## Getting Started

### Prerequisites

To explore and execute the project, you will need:

- MATLAB installed on your computer.
- The input datasets included in this repository.
- All required MATLAB source files and supporting functions.

### Running the Project

1. Clone the repository:

   ```bash
   git clone https://github.com/arafatfaisal/Cost-Effective-Optimal-Integration-of-Renewable-Energy-and-Waste-to-Energy-Technologies.git
   ```

2. Navigate to the project directory:

   ```bash
   cd Cost-Effective-Optimal-Integration-of-Renewable-Energy-and-Waste-to-Energy-Technologies
   ```

3. Open MATLAB.

4. Set the repository directory as the MATLAB working directory.

5. Ensure that the input data files and MATLAB functions are accessible through the MATLAB path.

6. Open and execute the main MATLAB script to initiate the simulation and optimization process.
## Repository Architecture

```text
Cost-Effective-Optimal-Integration/
│
├── README.md
├── LICENSE
│
├── data/
│   └── datasets/
│
├── src/
│   ├── main/
│   ├── optimization/
│   │   └── PSO/
│   ├── battery/
│   ├── economic/
│   └── visualization/
│
├── results/
│   └── figures/
│
└── CITATION.cff
```



**Important:** The main script may depend on the supporting MATLAB functions and input data files. Keep the original repository structure intact when running the project.

## Results and Visualization

The repository includes generated simulation outputs, graphical representations, and statistical results obtained during the research.

These outputs support the evaluation of:

- Hybrid microgrid optimization performance.
- PSO and GWO convergence behavior.
- Economic cost and NPC analysis.
- Battery charging and discharging characteristics.
- Energy generation and management.
- Comparative optimization performance.

For the detailed mathematical formulation, simulation parameters, and complete discussion of the results, please refer to the published journal article.

## Citation

If you use this repository or build upon this research, please cite the original publication:

```bibtex
@article{islam2025cost,
  title={Cost-Effective Optimal Integration of Renewable Energy and Waste-to-Energy Technologies},
  author={Islam, Md Sajjad-Ul and Zafar, Md. Arafat Bin and Islam, Md. Rashidul and Ikram, Arafat Ibne and Shafiullah, Md},
  journal={The Journal of Engineering},
  year={2025},
  doi={10.1049/tje2.70148}
}
```

**Publication link:** https://doi.org/10.1049/tje2.70148

## Acknowledgements

This work was conducted as an academic research project focusing on the optimal integration of renewable energy and waste-to-energy technologies for sustainable electricity generation.

The authors acknowledge the contributions of all researchers and institutions involved in the development and publication of this research.

## Author

**Md. Arafat Bin Zafar**

Electrical and Electronic Engineering | Medical Engineering Research

GitHub: [@arafatfaisal](https://github.com/arafatfaisal)

ORCID: [0000-0002-8908-5420](https://orcid.org/0000-0002-8908-5420)

---

*This repository is intended for academic, educational, and research purposes. Please refer to the published article for the complete methodology, assumptions, and experimental details.*

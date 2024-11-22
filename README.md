# ANSYS 2024 R2 INSTALLATION BUNDLE

## Overview

The purpose of this project was to create a custom installation bundle for ANSYS 2024 R2 using the PowerShell App Deployment Tool Kit (PSADT)

## Description

This project is meant to be a skeleton or basis to bundle Ansys products using PSADT in order to deploy the applications through SCCM/Intune

ANSYS Installation Version - 2024 R2

- The packs that these shells install are:
    - ANSYS Prep Post (Ansys Workbench)
    - ANSYS FluidStructures (Fluid and Structures Add-In)
    - ANSYS Electronics Desktop (AnsysEM)
    - ANSYS Granta EduPack

## Tools and Languages Used:

- **Language**: Microsoft PowerShell 5.1
- **Tools**: PowerShell App Deployment Tool Kit (PSADT) 3.10.2 <br>
**To download the latest version of PSDAT** - https://psappdeploytoolkit.com/

# How to Use

## Clone the Repository

git clone https://github.com/danielreisman40/ANSYS-Custom-Install-Bundle.git

## Configuration and Customization

### Configuration
1. Place your Ansys 2024 R2 packs in their respective "Files" folder that is in each Ansys Pack Bundle (e.g. Ansys Granta EduPack in the "Files" folder in "Ansys GRANTA EduPack Install")

2. Open the *Deploy-Application.ps1* script in the respective bundle folder and change the required parameters for your environment:
    - License/License Server
    - Installation Path
    - Shortcut Path

### Customization

These scripts can easily be adapted to other software deployments as needed
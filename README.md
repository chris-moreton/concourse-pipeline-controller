# Concourse Pipeline Initialiser

Scans specified Git code repositories for updates to pipeline configurations. When an update is detected, the new pipeline configuration is applied and the first job in the pipeline is triggered.

This allows developers working on the specified Git repositories to manage the pipeline without needing to install anything on their local machines.

It also enforeces a consistency of pipeline configuration across projects.

## Configuation

The list of repositories to be included is held in

    repositories.yml
    


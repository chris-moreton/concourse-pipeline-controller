# Concourse Pipeline Controller

This is a single-job Concourse pipeline that manages the pipelines of other services within the same Concourse instance.

It scans specified Git code repositories for updates to pipeline configurations. When an update is detected, to either the pipeline or the application code, the updated pipeline configuration is applied, if needed, and the pipeline is triggered.

This removes the need to have any special software installed locally, but also simplifies modifying a pipeline and its tasks, which would normaly require two steps:

* Push changes to GitHub
* Initialise the pipeline

By handing over the updating and triggering of pipelines to this controller, developers can push pipeline changes, pipeline task change, or application code changes and the controller will deal with it.

It also encourages a consistency of pipeline configuration across projects.  Certain conventions must be followed to use it. 

Various task files are provided that can be referenced directly in an application pipeline.

Full documentation can be found in the [wiki](https://github.com/chris-moreton/concourse-pipeline-controller/wiki/Netsensia-Deployment-Pipeline).

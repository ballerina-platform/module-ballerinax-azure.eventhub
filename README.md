Ballerina Azure Event Hubs Connector
===================

[![Build](https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/workflows/CI/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/actions?query=workflow%3ACI)
[![GitHub Last Commit](https://img.shields.io/github/last-commit/ballerina-platform/module-ballerinax-azure.eventhub.svg)](https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/commits/master)
[![GraalVM Check](https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/actions/workflows/build-with-bal-test-native.yml/badge.svg)](https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/actions/workflows/build-with-bal-test-native.yml)
[![License](https://img.shields.io/badge/License-Apache%202.0-blue.svg)](https://opensource.org/licenses/Apache-2.0)

[Azure Event Hubs](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-about) is a fully managed, real-time data ingress service that is highly scalable, secured, open, and reliable. It ingests data (events) from different sources and reliably distributes it between multiple independent systems for processing, storage, and analysis.

Azure Event Hubs [Ballerina](https://ballerina.io/) connector is used to connect with the Azure Event Hubs to ingest millions of events per second so that you can process and analyze the massive amounts of data produced by your connected devices and applications.

For more information, go to the module(s).
- [azure_eventhub](eventhub/Module.md)

## Building from the source

### Setting up the prerequisites

1. Download and install Java SE Development Kit (JDK) version 11. You can install either [OpenJDK](https://adoptopenjdk.net/) or [Oracle](https://www.oracle.com/java/technologies/javase-jdk11-downloads.html).

    > **Note:** Set the JAVA_HOME environment variable to the path name of the directory into which you installed JDK.

2. Download and install [Ballerina Swan Lake](https://ballerina.io/). 

### Building the source

Execute the commands below to build from the source.

- To build the package:
    ```shell
    bal build ./eventhub
    ```
- To test the package: 
    ```shell
    bal test ./eventhub
    ```

## Contributing to Ballerina

As an open source project, Ballerina welcomes contributions from the community. 

For more information, go to the [contribution guidelines](https://github.com/ballerina-platform/ballerina-lang/blob/master/eventhub/CONTRIBUTING.md).

## Code of conduct

All contributors are encouraged to read the [Ballerina Code of Conduct](https://ballerina.io/code-of-conduct).

## Useful links

* Discuss code changes of the Ballerina project in [ballerina-dev@googlegroups.com](mailto:ballerina-dev@googlegroups.com).
* Chat live with us via our [Discord server](https://discord.gg/ballerinalang).
* Post all technical questions on Stack Overflow with the [#ballerina](https://stackoverflow.com/questions/tagged/ballerina) tag.

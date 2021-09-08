## Overview

The [Ballerina](https://ballerina.io/) connector for Azure Event Hub provides access to the Azure Event Hub via the Ballerina Language. This connector allows you to ingest, buffer, store, and process high-frequency data from any source in real-time to derive important business insights using the Azure Event Hub. It provides the capability to perform Event Hub service operations, Event Hub management operations, handle publisher policy operations.

This module supports [Azure Event Hub REST API 2014-01 version](https://docs.microsoft.com/en-us/rest/api/eventhub/).

## Prerequisites

Before using this connector in your Ballerina application, complete the following:

* [Create an Azure account to access the Azure portal](https://docs.microsoft.com/en-us/learn/modules/create-an-azure-account/)

* [Create a resource group](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-create#create-a-resource-group)

* [Create a Event Hubs namespace](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-create#create-an-event-hubs-namespace)

* [Create an Event Hub](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-create#create-an-event-hub)

* Obtain tokens

    [Shared Access Signature (SAS) authentication credentials](https://docs.microsoft.com/en-us/azure/event-hubs/authenticate-shared-access-signature) are required to communicate with the Event Hub. These credentials are available in the connection string of the Event Hub namespace.

    1. Obtain the connection string for the Event Hub namespace by following the instructions given [here](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-get-connection-string#get-connection-string-from-the-portal).
        (Eg: `"Endpoint=sb://<Namespace_Name>.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=i1f2BXAbmtxhu............f9GMyfnNWvQ3CY="`)

    2. Extract the shared access key name, shared access key, and resource URI of the Event Hub namespace from the connection string. 
        * Shared access key name (Eg: `"RootManageSharedAccessKey"`)
        * Shared access key (Eg: `"i1f2BXAbmtxhu............f9GMyfnNWvQ3CY="`)
        * Resource URI to the Event Hub namespace (Eg: `"<Namespace_Name>.servicebus.windows.net"`)

## Quickstart

To use the Azure Event Hub connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import connector
Import the `ballerinax/azure_eventhub` module into the Ballerina project.
```ballerina
import ballerinax/azure_eventhub;
```

### Step 2: Create a new connector instance
Create an `azure_eventhub:ConnectionConfig` with the extracted shared access key name, shared access key, 
the resource uri and initialize the connector with it.
```ballerina
azure_eventhub:ConnectionConfig config = {
    sasKeyName: <SAS_KEY_NAME>,
    sasKey: <SAS_KEY>,
    resourceUri: <RESOURCE_URI> 
};

azure_eventhub:Client eventHubClient = check new (config);
```

### Step 3: Invoke connector operation
1. Now you can use the operations available within the connector. Note that they are in the form of remote operations.

    Following is an example on how to send an event to the Azure Event Hub using the connector.

    Send an event to the Azure Event Hub

    ```ballerina
    public function main() returns error? {
        map<string> brokerProps = {CorrelationId: "34", CorrelationId2: "83"};
        map<string> userProps = {Alert: "windy", warning: "true"};

        check eventHubClient->send(eventHubPath, eventData, userProps, brokerProps, partitionKey = "groupName");
        log:printInfo("Successfully Send Event to Event Hub!");
    }
    ```

2. Use `bal run` command to compile and run the Ballerina program.

**[You can find a list of samples here](https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/eventhub/samples)**

## Overview

The Azure Event Hub Ballerina Connector is used to connect Ballerina to the Azure Event Hub to ingest, buffer, store, 
and process high-frequency data from any source in real-time to derive important business insights.

This module supports Event hub service operations such as sending an event, sending batch events, 
sending partition events and sending events with partition ID. It also supports Event hub management operations like 
creating a new event hub, getting an event hub, updating an event hub, listing event hubs, deleting event hubs, 
creating a new consumer group, getting consumer groups, listing consumer groups, listing partitions, getting partitions, 
deleting consumer groups. The connector also provides the capability to handle publisher policy operations like getting 
revoked publishers, revoking a publisher, and resume publishers.

This module supports Azure Event Hub REST API [v2014-01](https://docs.microsoft.com/en-us/rest/api/eventhub/).

## Prerequisites

Before using this connector in your Ballerina application, complete the following:

* Create Azure Account to Access Azure Portal https://docs.microsoft.com/en-us/learn/modules/create-an-azure-account/

* Create Resource Group https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-create#create-a-resource-group

* Create Event Hubs Namespace https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-create#create-an-event-hubs-namespace

* Create Event Hub https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-create#create-an-event-hub 

* Obtain tokens

    Shared Access Signature (SAS) authentication credentials are required to communicate with the Event Hub. These credentials are available in the connection string of the Event Hub namespace.

    1. Obtain the connection string for the Event Hub namespace by following the instructions given [here](https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-get-connection-string#get-connection-string-from-the-portal).
    (Eg: "Endpoint=sb://<Namespace_Name>.servicebus.windows.net/;SharedAccessKeyName=RootManageSharedAccessKey;SharedAccessKey=i1f2BXAbmtxhu............f9GMyfnNWvQ3CY=")

    2. Extract the shared access key name, shared access key, and resource URI of the Event Hub namespace from the connection string. 
        * Shared access key name (Eg: "RootManageSharedAccessKey")
        * Shared access key (Eg: "i1f2BXAbmtxhu............f9GMyfnNWvQ3CY=")
        * Resource URI to the Event Hub namespace (Eg: "<Namespace_Name>.servicebus.windows.net")

* Configure the connector with obtained tokens

## Quickstart

To use the Azure Event Hub connector in your Ballerina application, update the .bal file as follows:

### Step 1: Import the Azure Event Hub ballerina library
Import the ballerinax/azure_eventhub module into the Ballerina project.
```ballerina
    import ballerinax/azure_eventhub;
```

### Step 2: Initialize the Azure Event Hub client
Use the extracted shared access key name, shared access key, and the resource uri to initialize the Azure Event Hub client.
```ballerina
    configurable string sasKeyName = ?;
    configurable string sasKey = ?;
    configurable string resourceUri = ?;

    azure_eventhub:ClientEndpointConfiguration config = {
        sasKeyName: sasKeyName,
        sasKey: sasKey,
        resourceUri: resourceUri 
    };
    azure_eventhub:Client publisherClient = check new (config);
```

### Step 3: Specify the broker properties and user properties
Define the optional broker properties and user properties to be sent with the event using a map.
```ballerina
    map<string> brokerProps = {CorrelationId: "34", CorrelationId2: "83"};
    map<string> userProps = {Alert: "windy", warning: "true"};
```

### Step 4: Send an event to the Azure Event Hub
You can now send an event to the Azure event hub by giving the event hub name, and the event hub data with the broker 
properties and user properties. You can also give a partition key to send events to the same partition with the given 
partition key name. Here we have sent an event with the string data “eventData” to the event hub named “mytesthub” with 
the partition key “groupName”.
```ballerina
    var sendResult = publisherClient->send("mytesthub", "eventData", userProps, brokerProps, partitionKey = "groupName");
    if (sendResult is error) {
        log:printError(sendResult.message());
    } else {
        log:printInfo("Successfully Send Event to Event Hub!");
    }
```

## Quick reference
Code snippets of some frequently used functions: 

* Send an event

```ballerina
   var result = eventHubClient->send("myhub", "eventData");
```

* Send an event with broker properties and user properties.

```ballerina
   map<string> brokerProps = {"CorrelationId": "32119834", "CorrelationId2": "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

   var result = eventHubClient->send("myhub", "eventData", userProps, brokerProps);
```

* Send an event with broker properties, user properties & partition key.
```ballerina
   map<string> brokerProps = {PartitionKey: "groupName1", CorrelationId: "32119834";
   map<string> userProps = {Alert: "windy", warning: "true"};

   var result = eventHubClient->send("myhub", "data", userProps, brokerProps, partitionKey = "groupName");
```

* Send an event with broker properties, user properties & partition id.
```ballerina
   map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

   var result = eventHubClient->send("myhub", "data", userProps, brokerProps, partitionId = 1);
```

* Send a batch event.
```ballerina
    map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    eventhub:BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var result = eventHubClient->sendBatch("myhub", batchEvent);
```

* Send a batch event with partition key.
```ballerina
    map<string> brokerProps = {PartitionKey: "groupName", CorrelationId: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    eventhub:BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var result = eventHubClient->sendBatch("myhub", batchEvent, partitionKey = "groupName");
```

* Send a batch event to partition.
```ballerina
    map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    eventhub:BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var result = eventHubClient->sendBatch("myhub", batchEvent, partitionId = 1);
```

* Send a batch event with publisher id
```ballerina
    map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    eventhub:BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var result = eventHubClient->sendBatch("myhub", batchEvent, publisherId = "device-1");
```

* Create a new event hub
```ballerina
   var result = eventHubClient->createEventHub("myhub");
```

* Get an event hub
```ballerina
    var result = eventHubClient->getEventHub("myhub");
```

* Delete a event hub
```ballerina
    var result = eventHubClient->deleteEventHub("myhub");
```

* Create a new consumer group
```ballerina
    var result = eventHubClient->createConsumerGroup("myhub", "groupName");
```

* Get consumer group
```ballerina
    var result = eventHubClient->getConsumerGroup("myhub", "groupName");
```

* Delete a consumer group
```ballerina
    var result = eventHubClient->deleteConsumerGroup("myhub", "groupName");
```

**[You can find a list of samples here](https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/eventhub/samples)**

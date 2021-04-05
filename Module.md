# Ballerina Azure Event Hubs Module

Connects to Microsoft Azure Event Hubs using Ballerina.

# Module Overview

Azure Event Hubs Ballerina Connector is used to connect with the Azure Event Hubs to ingest millions of events per 
second so that you can process and analyze the massive amounts of data produced by your connected devices and 
applications. Once data is collected into an Event Hub, it can be transformed and stored using any real-time 
analytics provider or batching/storage adapters.

Azure Event Hub Ballerina connector supports Event hub service operations like sending an event, sending batch events, 
sending partition events and sending events with partition ID. It also supports Event hub management operations like 
creating a new event hub, getting an event hub, updating an event hub, listing event hubs, deleting event hubs, 
creating a new consumer group, getting consumer groups, listing consumer groups, listing partitions, getting partitions, 
deleting consumer groups. The connector also provides the capability to handle publisher policy operations like getting 
revoked publishers, revoking a publisher, and resume publishers.

The connector will only be focusing on sending events to the event hub. The event hub connector will invoke the 
REST APIs exposed via the Azure Event Hub. https://docs.microsoft.com/en-us/rest/api/eventhub/.

The REST APIs fall into the following categories:
* Azure Resource Manager: APIs that perform resource manager operations, and have /providers/Microsoft.EventHub/ as part 
  of the request URI.
* Event Hubs service: APIs that enable operations directly on the Event Hubs service, and have 
  <namespace>.servicebus.windows.net/ in the request URI. The Event Hubs service API is focused on this implementation.

# Compatibility
|                     |    Version          |
|:-------------------:|:-------------------:|
| Ballerina Language  | Swan-Lake-Alpha3SNAP|

# Supported Operations

## Azure Event Hubs Service Operations
The `ballerinax/azure_eventhub` module contains operations related to accessing the Event Hubs service to perform 
operations on event hubs. It includes operations to send event, send event with broker properties and user properties, 
send event with partition key, send partition event, send batch events, send events with partition key, send batch 
event with publisher ID. 

## Azure Event Hubs Management Operations
The `ballerinax/azure_eventhub` module contains operations related to accessing the Event Hubs service to performing 
management operations on Event Hubs. It includes operations to create new event hub, get an event hub, 
update an event hub, list event hubs, delete an event hub, create a new consumer group, get consumer group, 
list consumer groups, list partitions, get partition, delete a consumer group. 

## Azure Event Hubs Publisher Policy Operations
The `ballerinax/azure_eventhub` module contains operations related to performing publisher policy operations on 
event hubs. It includes operations to revoke publisher, get revoked publishers, resume upblisher.

# Prerequisites:

* Azure Account to Access Azure Portal https://docs.microsoft.com/en-us/learn/modules/create-an-azure-account/

* A Resource Group https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-create#create-a-resource-group

* An Event Hubs Namespace https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-create#create-an-event-hubs-namespace

* An Event Hub https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-create#create-an-event-hub 

* Connection String of the Event Hub Namespace
We need management credentials to communicate with the Event Hubs. These credentials are available in the connection 
string of the Event Hub namespace. Obtain the connection string for the Event Hubs namespace by following the 
instructions given below.
https://docs.microsoft.com/en-us/azure/event-hubs/event-hubs-get-connection-string#get-connection-string-from-the-portal

* Shared Access Signature (SAS) Authentication Credentials
You need to extract the Shared Access Key Name, Shared Access Key, Resource URI to the Event Hub Namespace separately 
from the connection string.
    * Shared Access Key Name, 
    * Shared Access Key, 
    * Resource URI to the Event Hub Namespace.

# Quickstart(s):

## Publish Events to an Azure Event Hub 

This is the simplest scenario to send events to an Azure Event Hub. You need to obtain a connection string of the 
name space of the event hub you want to send events. 

### Step 1: Import the Azure Event Hub Ballerina Library
First, import the ballerinax/azure_eventhub module into the Ballerina project.
```ballerina
    import ballerinax/azure_eventhub;
```

### Step 2: Initialize the Azure Event Hub PublisherClient
You can now make the connection configuration using the shared access key name, shared access key, and the resource 
URI to the event hub namespace.
```ballerina
    configurable string sasKeyName = ?;
    configurable string sasKey = ?;
    configurable string resourceUri = ?;

    azure_eventhub:ClientEndpointConfiguration config = {
        sasKeyName: sasKeyName,
        sasKey: sasKey,
        resourceUri: resourceUri 
    };
    azure_eventhub:PublisherClient publisherClient = checkpanic new (config);
```
Note:
You must specify the SAS key name, SAS key and the resource URI when configuring the Azure Event Hub Client connector.

### Step 3: Specify the (Optional) Broker Properties and User Properties
You can now define the optional broker properties and user properties to be sent with the event using a map.
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
Note:
You can specify the event hub path and the event data as parameters of the send method.
This operation will return a ballerina error if the operation failed.


## Entity Management in an Azure Event Hub 
This is the simplest scenario to manage entities related to azure event hubs. You need to obtain a connection string of 
the name space of the event hub you want to send events. 

### Step 1: Import the Azure Event Hub Ballerina Library
First, import the ballerinax/azure_eventhub module into the Ballerina project.
```ballerina
    import ballerinax/azure_eventhub;
```

### Step 2: Initialize the Azure Event Hub ManagementClient
You can now make the connection configuration using the shared access key name, shared access key, and the resource URI 
to the event hub namespace.
```ballerina
    configurable string sasKeyName = ?;
    configurable string sasKey = ?;
    configurable string resourceUri = ?;

    azure_eventhub:ClientEndpointConfiguration config = {
        sasKeyName: sasKeyName,
        sasKey: sasKey,
        resourceUri: resourceUri 
    };
    azure_eventhub:PublisherClient publisherClient = checkpanic new (config);
```
Note:
You must specify the SAS key name, SAS key and the resource URI when configuring the Azure Event Hub Client connector.

### Step 3: Create a new event hub
You need to specify the event hub name as a parameter to create a new event hub. Here we are creating an event hub 
named “mytesthub”. 
```ballerina
    var createResult = managementClient->createEventHub("mytesthub");
    if (createResult is error) {
        log:printError(createResult.message());
    }
    if (createResult is xml) {
        log:printInfo(createResult.toString());
        log:printInfo("Successfully Created Event Hub!");
    }

```
Note:
You can specify the event hub path as a parameter of the createEventHub method.
This operation will return a ballerina error if the operation failed.


### Step 4: Get an event hub 
You need to specify the event hub name as a parameter to get all the metadata associated with the specified event hub. 
Here we are getting all the metadata associated with the event hub named “mytesthub”.
```ballerina
    var getEventHubResult = managementClient->getEventHub("mytesthub");
    if (getEventHubResult is error) {
        log:printError(getEventHubResult.message());
    }
    if (getEventHubResult is xml) {
        log:printInfo(getEventHubResult.toString());
        log:printInfo("Successfully Get Event Hub!");
    }
```
Note:
You can specify the event hub path as a parameter of the getEventHub method.
This operation will return a ballerina error if the operation failed.

### Step 5: Update an event hub 
You need to specify the event hub name as a parameter and EventHubDecsriptionToUpdate record with message retention in 
days property to update the properties of the event hub. Here we are updating the properties associated with the event 
hub named “mytesthub”.
```ballerina
    azure_eventhub:EventHubDescriptionToUpdate eventHubDescriptionToUpdate = {
        MessageRetentionInDays: 5
    };
    var updateResult = managementClient->updateEventHub("mytesthub", eventHubDescriptionToUpdate);
    if (updateResult is error) {
        log:printError(updateResult.message());
    }
    if (updateResult is xml) {       
        log:printInfo(updateResult.toString());
        log:printInfo("Successfully Updated Event Hub!");
    }
```
Note:
You can specify the event hub path and event hub description of  record type EventHubDescriptionToUpdate as a parameter 
of the updateEventHub method.
This operation will return a ballerina error if the operation failed.

### Step 6: List event hubs
You need to specify the event hub name as a parameter to get all the metadata associated with the specified event hubs 
in the namespace. Here we are getting all the metadata associated with the event hubs in the specified namespace.
```ballerina
    var listResult = managementClient->listEventHubs();
    if (listResult is error) {
        log:printError(listResult.message());
    }
    if (listResult is xml) {
        log:printInfo(listResult.toString());
        log:printInfo("Successfully Listed Event Hubs!");
    }
```
Note:
This operation will return a ballerina error if the operation failed.

### Step 7: Delete a event hub
You need to specify the event hub name as a parameter to delete an event hub. This is the basic scenario of deleting 
an event hub named “mytesthub”. 
```ballerina
    var deleteResult = managementClient->deleteEventHub("mytesthub");
    if (deleteResult is error) {
        log:printError(msg = deleteResult.message());
    } else {
        log:printInfo("Successfully Deleted Event Hub!");
    }
```
Note:
You can specify the event hub path as a parameter of the deleteEventHub method.
This operation will return a ballerina error if the operation failed.

# Samples:

1. Sending an event.

```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:PublisherClient eventHubClient = checkpanic new (config);
   var result = eventHubClient->send("myhub", "eventData");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_event.bal

2. Sending an event with broker properties and user properties.

```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:PublisherClient eventHubClient = checkpanic new (config);
   map<string> brokerProps = {"CorrelationId": "32119834", "CorrelationId2": "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

   var result = eventHubClient->send("myhub", "eventData", userProps, brokerProps);
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_event_with_broker_and_user_properties.bal

3. Sending an event with broker properties, user properties & partition key.
```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:PublisherClient eventHubClient = checkpanic new (config);
   map<string> brokerProps = {PartitionKey: "groupName1", CorrelationId: "32119834";
   map<string> userProps = {Alert: "windy", warning: "true"};

   var result = eventHubClient->send("myhub", "data", userProps, brokerProps, partitionKey = "groupName");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_event_with_partition_key.bal

4. Sending an event with broker properties, user properties & partition id.
```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:PublisherClient eventHubClient = checkpanic new (config);
   map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
   map<string> userProps = {Alert: "windy", warning: "true"};

   var result = eventHubClient->send("myhub", "data", userProps, brokerProps, partitionId = 1);
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_partition_event.bal

5. Sending a batch event.
```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:PublisherClient eventHubClient = checkpanic new (config);
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
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_batch_event.bal

6. Sending a batch event with partition key.
```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:PublisherClient eventHubClient = checkpanic new (config);
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
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_batch_event_with_partition_key.bal

7. Sending a batch event to partition.
```ballerina
import ballerinax/azure_eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:PublisherClient eventHubClient = checkpanic new (config);
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
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_batch_event_to_partition.bal

8. Sending a batch event with publisher id
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:PublisherClient eventHubClient = checkpanic new (config);
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
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/send_batch_event_with_publisherId.bal

9. Create a new event hub
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:ManagementClient eventHubClient = checkpanic new (config);
   var result = eventHubClient->createEventHub("myhub");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/create_event_hub.bal

10. Get an event hub
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:ManagementClient eventHubClient = checkpanic new (config);
   var result = eventHubClient->getEventHub("myhub");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/get_event_hub.bal


11. Delete a event hub
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:ManagementClient eventHubClient = checkpanic new (config);
   var result = eventHubClient->deleteEventHub("myhub");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/delete_event_hub.bal

12. Create a new consumer group
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:ManagementClient eventHubClient = checkpanic new (config);
   var result = eventHubClient->createConsumerGroup("myhub", "groupName");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/create_consumer_group.bal

13. Get consumer group
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:ManagementClient eventHubClient = checkpanic new (config);
   var result = eventHubClient->getConsumerGroup("myhub", "groupName");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/get_consumer_group.bal


14. Delete a consumer group
```ballerina
import ballerinax/azure.eventhub as eventhub;

public function main() {
   eventhub:ClientEndpointConfiguration config = {
       sasKeyName: "<sas_key_name>",
       sasKey: "<sas_key>",
       resourceUri: "<resource_uri>"
   };
   eventhub:ManagementClient eventHubClient = checkpanic new (config);
   var result = eventHubClient->deleteConsumerGroup("myhub", "groupName");
}
```
Sample is available at:
https://github.com/ballerina-platform/module-ballerinax-azure.eventhub/blob/master/samples/delete_consumer_groups.bal

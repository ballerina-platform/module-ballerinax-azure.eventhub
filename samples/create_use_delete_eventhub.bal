import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;

public function main() {
    azure_eventhub:ClientEndpointConfiguration config = {
        sasKeyName: config:getAsString("SAS_KEY_NAME"),
        sasKey: config:getAsString("SAS_KEY"),
        resourceUri: config:getAsString("RESOURCE_URI") 
    };
    azure_eventhub:ManagementClient managementClient = new (config);
    azure_eventhub:PublisherClient publisherClient = new (config);

    // ------------------------------------ Event Hub Creation-----------------------------------------------
    azure_eventhub:EventHubDescription eventHubDescription = {
        MessageRetentionInDays: 3,
        PartitionCount: 8
    };
    var createResult = managementClient->createEventHub("mytesthub", eventHubDescription);
    if (createResult is error) {
        log:printError(createResult.message());
    }
    if (createResult is xml) {
        log:print(createResult.toString());
        log:print("Successfully Created Event Hub!");
    }

    // ----------------------------------------- Send Event ------------------------------------------------
    map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    var sendResult = publisherClient->send("mytesthub", "eventData", userProps, brokerProps, 
        partitionKey = "groupName");
    if (sendResult is error) {
        log:printError(sendResult.message());
    } else {
        log:print("Successfully Send Event to Event Hub!");
    }

    // ------------------------------- Send Batch Event with Partition Key -----------------------------------------
    azure_eventhub:BatchEvent batchEvent = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var sendBatchResult = publisherClient->sendBatch("mytesthub", batchEvent, partitionKey = "groupName");
    if (sendBatchResult is error) {
        log:printError(sendBatchResult.message());
    } else {
        log:print("Successfully Send Batch Event to Event Hub!");
    } 

    // --------------------------------- Delete Event Hub ----------------------------------------------------
    var deleteResult = managementClient->deleteEventHub("mytesthub");
    if (deleteResult is error) {
        log:printError(msg = deleteResult.message());
    } else {
        log:print("Successfully Deleted Event Hub!");
    }    
}

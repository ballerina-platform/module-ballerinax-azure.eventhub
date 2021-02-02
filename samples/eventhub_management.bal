import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;

public function main() {
    azure_eventhub:ClientEndpointConfiguration config = {
        sasKeyName: config:getAsString("SAS_KEY_NAME"),
        sasKey: config:getAsString("SAS_KEY"),
        resourceUri: config:getAsString("RESOURCE_URI") 
    };
    azure_eventhub:Client c = new (config);

    // ------------------------------------ Event Hub Creation-----------------------------------------------
    var createResult = c->createEventHub("mytesthub");
    if (createResult is error) {
        log:printError(createResult.message());
    }
    if (createResult is xml) {
        log:print(createResult.toString());
        log:print("Successfully Created Event Hub!");
    }

    // ----------------------------------- Get Event Hub -----------------------------------------------------
    var getEventHubResult = c->getEventHub("mytesthub");
    if (getEventHubResult is error) {
        log:printError(getEventHubResult.message());
    }
    if (getEventHubResult is xml) {
        log:print(getEventHubResult.toString());
        log:print("Successfully Get Event Hub!");
    } 

    // --------------------------------- Update Event Hub --------------------------------------------------
    azure_eventhub:EventHubDescriptionToUpdate eventHubDescriptionToUpdate = {
        MessageRetentionInDays: 5
    };
    var updateResult = c->updateEventHub("mytesthub", eventHubDescriptionToUpdate);
    if (updateResult is error) {
        log:printError(updateResult.message());
    }
    if (updateResult is xml) {
        log:print(updateResult.toString());
        log:print("Successfully Updated Event Hub!");
    }

    // ---------------------------------- List Event Hubs -----------------------------------------------------
    var listResult = c->listEventHubs();
    if (listResult is error) {
        log:printError(listResult.message());
    }
    if (listResult is xml) {
        log:print(listResult.toString());
        log:print("Successfully Listed Event Hubs!");
    }

    // --------------------------------- Delete Event Hub ----------------------------------------------------
    var deleteResult = c->deleteEventHub("mytesthub");
    if (deleteResult is error) {
        log:printError(msg = deleteResult.message());
    } else {
        log:print("Successfully Deleted Event Hub!");
    }    
}
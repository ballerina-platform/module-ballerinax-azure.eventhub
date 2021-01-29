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

    azure_eventhub:EventHubDescriptionToUpdate eventHubDescriptionToUpdate = {
        MessageRetentionInDays: 5
    };
    var b = c->updateEventHub("myhub", eventHubDescriptionToUpdate);
    if (b is error) {
        log:printError(b.message());
    }
    if (b is xml) {
        log:print(b.toString());
        log:print("Successful!");
    }
}

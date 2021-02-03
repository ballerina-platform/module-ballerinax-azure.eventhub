import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;

public function main() {
    azure_eventhub:ClientEndpointConfiguration config = {
        sasKeyName: config:getAsString("SAS_KEY_NAME"),
        sasKey: config:getAsString("SAS_KEY"),
        resourceUri: config:getAsString("RESOURCE_URI") 
    };
    azure_eventhub:PublisherClient publisherClient = new (config);

    var result = publisherClient->getRevokedPublishers("myeventhub");
    if (result is error) {
        log:printError(result.message());
    }
    if (result is xml) {
        log:print("listReceived");
        log:print(result.toString());
        log:print("Successful!");
    }
}

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

    map<string> brokerProps = {PartitionKey: "groupName1", CorrelationId: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    // partition key used as the parameter is prioritized over the partition key provided in the brokerProperties
    var result = publisherClient->send("myeventhub", "data", userProps, brokerProps, partitionKey = "groupName");
    if (result is error) {
        log:printError(result.message());
    } else {
        log:print("Successful!");
    }
}

import ballerinax/azure_eventhub;
import ballerina/config;
import ballerina/log;
import ballerina/jsonutils;

public function main() {
    azure_eventhub:ClientEndpointConfiguration config = {
        sasKeyName: config:getAsString("SAS_KEY_NAME"),
        sasKey: config:getAsString("SAS_KEY"),
        resourceUri: config:getAsString("RESOURCE_URI") 
    };
    azure_eventhub:Client c = new (config);

    var b = c->getRevokedPublishers("myeventhub");
    if (b is error) {
        log:printError(b.message());
    }
    if (b is xml) {
        log:print("listReceived");
        json|error signedIdentifiers = jsonutils:fromXML(b);
        log:print(signedIdentifiers.toString());
        log:print("Successful!");
    }
}

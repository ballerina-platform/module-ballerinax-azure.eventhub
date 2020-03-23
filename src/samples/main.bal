import eventhub;
import ballerina/io;

public function main() {
    eventhub:ClientEndpointConfiguration config = {
        sasKeyName: "dev",
        sasKey: "aaaaa",
        resourceUri: "abc.com"
    };
    eventhub:Client c = <eventhub:Client>new eventhub:Client(config);
    map<string> brokerProps = {CorrelationId: "32119834", CorrelationId2: "32119834"};
    map<string> userProps = {Alert: "windy", warning: "true"};

    eventhub:BatchEvent eventBatch = {
        events: [
            {data: "Message1"},
            {data: "Message2", brokerProperties: brokerProps},
            {data: "Message3", brokerProperties: brokerProps, userProperties: userProps}
        ]
    };
    var b = c->resumePublisher("hello");
    io:println(b);
}

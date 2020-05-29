Azure EventHub Connector
[//]: # (above is the module summary)


# Module Overview
## Sample

```ballerina
import ballerinax/azure.eventhub as eventhub;
import ballerina/io;

public function main() {

    eventhub:ClientEndpointConfiguration config = {
        sasKeyName: "",
        sasKey: "",
        resourceUri: "abc.com"
    };
    eventhub:Client c = <eventhub:Client>new eventhub:Client(config);
    map<string> brokerProps = {CorrelationId: "32119834"};
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
```


// Copyright (c) 2020, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
//
// WSO2 Inc. licenses this file to you under the Apache License,
// Version 2.0 (the "License"); you may not use this file except
// in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing,
// software distributed under the License is distributed on an
// "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
// KIND, either express or implied.  See the License for the
// specific language governing permissions and limitations
// under the License.

import ballerina/lang.'xml as xmllib;
import ballerina/xmlutils;

# Convert batch event to json
#
# + batchEvent - batch event 
# + return - Return eventhub formatted json
isolated function getBatchEventJson(BatchEvent batchEvent) returns json {
    json[] message = [];
    foreach var item in batchEvent.events {
        json data = checkpanic item.data.cloneWithType(json);
        json j = {
            Body: data
        };
        if (!(item["userProperties"] is ())) {
            json userProperties = {UserProperties:checkpanic item["userProperties"].cloneWithType(json)};
            j = checkpanic j.mergeJson(userProperties);
        }
        if (!(item["brokerProperties"] is ())) {
            json brokerProperties = {BrokerProperties:checkpanic item["brokerProperties"].cloneWithType(json)};
            j = checkpanic j.mergeJson(brokerProperties);
        }
        message.push(j);
    }
    return message;
}

# Convert eventhub description to xml
#
# + descriptionProperties - eventhub or consumer group description
# + return - Return eventhub formatted json
isolated function getDescriptionProperties(EventHubDescription|EventHubDescriptionToUpdate|ConsumerGroupDescription
    |RevokePublisherDescription descriptionProperties, xmllib:Element description) returns xml {
    json descriptionJson = checkpanic descriptionProperties.cloneWithType(json);
    xml eventHubDescriptionXml = checkpanic xmlutils:fromJSON(descriptionJson);
    xmllib:Element entry = <xmllib:Element> xml `<entry xmlns='http://www.w3.org/2005/Atom'/>`;
    xmllib:Element content = <xmllib:Element> xml `<content type='application/xml'/>`;
    description.setChildren(eventHubDescriptionXml);
    content.setChildren(description);
    entry.setChildren(content);
    return entry;
}

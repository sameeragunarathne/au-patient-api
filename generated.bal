// Copyright (c) 2023, WSO2 LLC. (http://www.wso2.com). All Rights Reserved.

// This software is the property of WSO2 LLC. and its suppliers, if any.
// Dissemination of any information or reproduction of any material contained
// herein is strictly forbidden, unless permitted by WSO2 in accordance with
// the WSO2 Software License available at: https://wso2.com/licenses/eula/3.2
// For specific language governing the permissions and limitations under
// this license, please see the license as well as any agreement you’ve
// entered into with WSO2 governing the purchase of this software and any
// associated services.
//
//
// AUTO-GENERATED FILE. DO NOT MODIFY.
//
// This file is auto-generated by WSO2 Healthcare Team for managing utility functions.
// It should not be modified by hand.

import wso2healthcare/healthcare.fhir.r4;
import ballerina/lang.value;
import ballerina/log;
import ballerina/http;

isolated final readonly & r4:FHIRSourceConnectInteraction srcConnectImpl = {
    read: patientReadImpl,
    search: patientSearchImpl,
    create: patientCreateImpl
};
//Default profile is set to International Resource URL
final readonly & string defaultProfile = "http://hl7.org.au/fhir/StructureDefinition/au-patient";

isolated function patientSearchImpl(map<r4:RequestSearchParameter[]> params, http:RequestContext ctx) returns r4:BundleEntry[]|r4:FHIRError? {

    lock {
        r4:FHIRContext fhirContext = check r4:getFHIRContext(ctx);

        value:Cloneable|object {} activeProfile = defaultProfile;

        // Since profile based function implementation is applied for search operation, 
        // active profile is retreived from the context.
        if fhirContext.getRequestSearchParameters().hasKey("_profile") {
            activeProfile = ctx.get("_OH_activeProfile");
        }

        PatientSourceConnect sourceConnect = profileImpl.get(defaultProfile);
        if activeProfile is string {
            log:printDebug(string `[SearchImpl] Current profile is  ${activeProfile}`);
            sourceConnect = profileImpl.get(activeProfile);
        }
        log:printDebug(string `[SearchImpl] Calling source system with parameters  ${params.toBalString()}`);
        r4:Bundle|Patient[] patients = check sourceConnect.search(params.clone(), fhirContext);
        r4:BundleEntry[] entries = [];

        if patients is r4:Bundle {
            entries = patients.entry ?: [];
        } else if patients is Patient[] {
            foreach Patient item in patients {
                r4:BundleEntry entry = {
                    fullUrl: "",
                    'resource: item
                };
                entries.push(entry);
            }
        }
        log:printDebug(string `[SearchImpl] Resultant entries list:  ${entries.toJsonString()}`);
        return entries.clone();
    }
}

isolated function patientReadImpl(string id, http:RequestContext ctx) returns r4:FHIRResourceEntity|r4:FHIRError {

    lock {
        log:printDebug(string `[ReadImpl] Calling source system with Id:  ${id}`);
        PatientSourceConnect sourceConnect = profileImpl.get(defaultProfile);
        r4:FHIRContext fhirContext = check r4:getFHIRContext(ctx);

        Patient patient = check sourceConnect.read(id, fhirContext);
        log:printDebug(string `[ReadImpl] Retrieved resource:  ${patient.toJsonString()}`);

        r4:FHIRResourceEntity entity = new (patient);
        return entity;
    }
}

isolated function patientCreateImpl(r4:FHIRResourceEntity resourceEntity, http:RequestContext ctx) returns string|r4:FHIRError {

    lock {
        PatientSourceConnect sourceConnect = profileImpl.get(defaultProfile);
        r4:FHIRContext fhirContext = check r4:getFHIRContext(ctx);

        value:Cloneable resourceRecord = resourceEntity.unwrap();

        if resourceRecord is Patient {
            log:printDebug(string `[CreateImpl] Request payload: ${resourceRecord.toString()}`);
            string|r4:FHIRError createResponse = check sourceConnect.create(resourceEntity, fhirContext);
            return createResponse;
        } else {
            string diagMsg = string `Expected r4:Patient FHIR resource model not found. Instead, found a model of type:" ${(typeof resourceRecord).toBalString()}`;
            return r4:createInternalFHIRError("Incoming r4:Patient resource model not found", r4:ERROR, r4:PROCESSING_NOT_FOUND, diagnostic = diagMsg);
        }
    }
}

public type PatientSourceConnect object {
    isolated function profile() returns r4:uri;
    isolated function read(string id, r4:FHIRContext ctx) returns Patient|r4:FHIRError;
    isolated function search(map<r4:RequestSearchParameter[]> searchParameters, r4:FHIRContext ctx) returns r4:Bundle|Patient[]|r4:FHIRError;
    isolated function create(r4:FHIRResourceEntity patient, r4:FHIRContext ctx) returns string|r4:FHIRError;
};

public type ProfileImplementations record {
    map<PatientSourceConnect> sourceConnectImplementations;
};

import wso2healthcare/healthcare.fhir.r4.aubase410;
import wso2healthcare/healthcare.fhir.r4;

public type ClinicalPatient record {
    string title?;
    string firstName;
    string lastName?;
    string preferredName?;
    string middleName?;
    string dateOfBirth?;
    int ethnicityId?;
    record {
        string name?;
        int 'order?;
        int id?;
        string createdDate?;
    } ethnicity?;
    record {
        string number?;
        string 'type?;
    } dvaCard?;
    string sex?;
    string homePhone?;
    record {
        int referredToUserId?;
        int referredBy?;
        string referredByType?;
        boolean indefinite?;
        string referralDate?;
        string firstVisitDate?;
    }[] incomingReferrals?;
    string mobilePhone?;
    record {
        string number?;
        string 'type?;
        string expiry?;
    } pensionCard?;
    string contactMethod?;
    string comment?;
    string occupation?;
    boolean pbsCoPaymentRelief?;
    boolean isDeceased?;
    boolean isAccountActive?;
    boolean optOutDataExtraction?;
    boolean hasNoKnownAllergy?;
    string usualBillingAccount?;
    record {
        string addressLine1?;
        string addressLine2?;
        string city?;
        string postCode?;
        string state?;
        int id?;
        string createdDate?;
        string modifiedDate?;
        int modifiedById?;
    } address?;
    record {
        int patientId?;
        string number?;
        string irn?;
        string expiry?;
        int id?;
        string createdDate?;
        string modifiedDate?;
        int modifiedById?;
    } medicareCard?;
    record {
        int patientId?;
        string number?;
        string status?;
        string verificationStatus?;
        int id?;
        string createdDate?;
        string modifiedDate?;
        int modifiedById?;
    } healthcareIdentifier?;
    int organisationId?;
    string alcoholConsumption?;
    string smokingStatus?;
    string[] allergies?;
    string bloodGroup?;
    record {
        int patientId?;
        int locationId?;
        string externalId?;
        int id?;
        string createdDate?;
    }[] locations?;
    boolean hasNoSignificantPMH?;
    int id?;
    string createdDate?;
    string modifiedDate?;
    int modifiedById?;
    string pronouns?;
};

public type ClinicalPatientSummary record {
    int id?;
    string name?;
    string dateOfBirth?;
    string address?;
    boolean returningPatient?;
};

public type ClinicalPatientSearchResponse record {
    ClinicalPatientSummary[] results?;
    int currentPage?;
    int pageCount?;
    int pageSize?;
    int rowCount?;
};

# Maps clinical patient response to FHIR patient model.
#
# + clinicalPatientSearchResponse - Parameter Description
# + return - Return Value Description
isolated function clinicalPatientSearchResponseToFHIR(ClinicalPatientSearchResponse clinicalPatientSearchResponse) returns aubase410:AUBasePatient[] {
    var results = clinicalPatientSearchResponse.results;
    if (results is ClinicalPatientSummary[]) {
        return results.map(clinicalPatientSummaryToFHIR);
    } else {
        return [];
    }
};

isolated function clinicalPatientSummaryToFHIR(ClinicalPatientSummary clinicalPatientSummary) returns aubase410:AUBasePatient => {
    meta: {
        profile: ["http://hl7.org.au/fhir/StructureDefinition/au-patient"]
    },
    id: clinicalPatientSummary.id.toString(),
    name: [
        {
            family: clinicalPatientSummary.name
        }
    ],
    birthDate: clinicalPatientSummary.dateOfBirth,
    address: [
        {
            line: [clinicalPatientSummary.address ?: ""]
        }
    ]
};

isolated function clinicalPatientToFHIR(ClinicalPatient clinicalPatient) returns aubase410:AUBasePatient => {
    meta: {
        profile: ["http://hl7.org.au/fhir/StructureDefinition/au-patient"]
    },
    birthDate: clinicalPatient.dateOfBirth,
    name: [
        {
            family: clinicalPatient.lastName,
            given: [clinicalPatient.firstName]
        }
    ],
    telecom: [
        {
            system: r4:phone,
            use: r4:mobile,
            value: clinicalPatient.mobilePhone
        },
        {
            system: r4:phone,
            use: r4:home,
            value: clinicalPatient.homePhone
        }
    ],
    address: [
        {
            line: [clinicalPatient.address?.addressLine1 ?: ""],
            city: clinicalPatient.address?.city,
            postalCode: clinicalPatient.address?.postCode,
            state: clinicalPatient.address?.state
        }
    ],
    gender: mapGendertoFHIRGender(clinicalPatient.sex),
    deceasedBoolean: clinicalPatient.isDeceased,
    managingOrganization: {
        reference: "Organization/" + clinicalPatient.organisationId.toString()
    }
};

# Maps FHIR patient model to ClinicalPatient model.
#
# + patient - FHIR patient model
# + return - Mapped ClinicalPatient model
isolated function fhirPatientToClinicalPatient(aubase410:AUBasePatient patient) returns ClinicalPatient {
    ClinicalPatient clinicalPatient = {
        dateOfBirth: patient.birthDate,
        firstName: "",
        isDeceased: patient.deceasedBoolean,
        sex: mapGendertoFHIRGender(patient.gender)
    };
    r4:HumanName[]? names = patient.name;
    if names is r4:HumanName[] {
        if names.length() > 0 {
            r4:HumanName name = names[0];
            if name.family is string {
                clinicalPatient.lastName = name.family;
            }
            if name.given is string[] {
                string[] givenNames = <string[]>name.given;
                if givenNames.length() > 0 {
                    clinicalPatient.firstName = givenNames[0];
                }
            }
        }
    }
    r4:ContactPoint[]? telecom = patient.telecom;
    if telecom is r4:ContactPoint[] {
        if telecom.length() > 0 {
            r4:ContactPoint contactPoint = telecom[0];
            if contactPoint.value is string {
                if contactPoint.use ==r4:mobile {
                    clinicalPatient.mobilePhone = contactPoint.value;
                } else if contactPoint.use == r4:home {
                    clinicalPatient.homePhone = contactPoint.value;
                }
            }
        }
    } 
    r4:Address[]? addresses = patient.address;
    if addresses is r4:Address[] {
        if addresses.length() > 0 {
            r4:Address address = addresses[0];
            if address.line is string[] {
                string[] addressLines = <string[]>address.line;
                if addressLines.length() > 0 {
                    clinicalPatient.address = {
                        addressLine1: addressLines[0],
                        city: address.city,
                        postCode: address.postalCode,
                        state: address.state
                    };
                }
            }
        }
    }
    return clinicalPatient;
}

# Maps clinical patient gender values to FHIR Gender values.
#
# + gender - Clinical gender value
# + return - Mapped FHIR gender value
isolated function mapGendertoFHIRGender(string? gender) returns aubase410:PatientGender? {
    match gender {
        "Male" => {
            return aubase410:CODE_GENDER_MALE;
        }
        "Female" => {
            return aubase410:CODE_GENDER_FEMALE;
        }
        _ => {
            return aubase410:CODE_GENDER_UNKNOWN;
        }
    }
}

# Maps FHIR gender values to clinical patient gender values.
#
# + gender - FHIR gender value
# + return - Mapped Clinical gender value
isolated function mapFHIRGendertoGender(aubase410:PatientGender? gender) returns string? {
    match gender {
        aubase410:CODE_GENDER_MALE => {
            return "Male";
        }
        aubase410:CODE_GENDER_FEMALE => {
            return "Female";
        }
        _ => {
            return "Unknown";
        }
    }
}

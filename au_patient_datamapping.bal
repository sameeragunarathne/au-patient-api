import wso2healthcare/healthcare.fhir.r4.aubase410;

public type CustomPatient record {
    string title?;
    string pronouns?;
    string firstName;
    string lastName?;
    string middleName?;
    string dateOfBirth?;
    int ethnicityId?;
    Gender sex?;
    string homePhone?;
    string mobilePhone?;
    string email?;
    string contactMethod?;
    boolean isAccountActive?;
    boolean isDeceased?;
    CustomAddress address?;
    IncomingReferrals[] incomingReferrals?;
};

public type CustomAddress record {
    string addressLine1?;
    string postCode?;
    string city?;
    string state?;
};

public type IncomingReferrals record {
    int referredToUserId?;
    int referredBy?;
    string referredByType?;
    boolean indefinite?;
    string referralDate?;
    string firstVisitDate?;
};

public enum Gender {
    FEMALE = "Female",
    MALE = "Male",
    UNKNOWN = "Unknown"
}

isolated function customPatientToFHIR(CustomPatient customPatient) returns aubase410:AUBasePatient => {
    meta: {
        profile: ["http://hl7.org.au/fhir/StructureDefinition/au-patient"]
    },
    birthDate: customPatient.dateOfBirth,
    name: [
        {
            family: customPatient.lastName,
            given: [customPatient.firstName]
        }
    ],
    telecom: [
        {
            system: "phone",
            value: customPatient.mobilePhone
        }
    ],
    address: [
        {
            line: [customPatient.address?.addressLine1 ?: ""],
            city: customPatient.address?.city,
            postalCode: customPatient.address?.postCode,
            state: customPatient.address?.state
        }
    ]
};

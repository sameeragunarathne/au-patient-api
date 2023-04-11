import wso2healthcare/healthcare.fhir.r4.aubase410;

public type MedinetPatient record {
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
    MedinetAddress address?;
    IncomingReferrals[] incomingReferrals?;
};

public type MedinetAddress record {
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

isolated function medinetPatientToFHIR(MedinetPatient medinetPatient) returns aubase410:AUBasePatient => {
    meta: {
        profile: ["http://hl7.org.au/fhir/StructureDefinition/au-patient"]
    },
    birthDate: medinetPatient.dateOfBirth,
    name: [
        {
            family: medinetPatient.lastName,
            given: [medinetPatient.firstName]
        }
    ],
    telecom: [
        {
            system: "phone",
            value: medinetPatient.mobilePhone
        }
    ],
    address: [
        {
            line: [medinetPatient.address?.addressLine1 ?: ""],
            city: medinetPatient.address?.city,
            postalCode: medinetPatient.address?.postCode,
            state: medinetPatient.address?.state
        }
    ]
};

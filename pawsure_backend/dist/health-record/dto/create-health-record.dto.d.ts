export declare enum HealthRecordType {
    VACCINATION = "Vaccination",
    VET_VISIT = "Vet Visit",
    MEDICATION = "Medication",
    ALLERGY = "Allergy",
    NOTE = "Note"
}
export declare class CreateHealthRecordDto {
    recordType: HealthRecordType;
    date: string;
    notes?: string;
}

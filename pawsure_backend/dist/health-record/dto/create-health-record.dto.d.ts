export declare enum HealthRecordType {
    VACCINATION = "Vaccination",
    VET_VISIT = "Vet Visit",
    MEDICATION = "Medication",
    ALLERGY = "Allergy",
    NOTE = "Note"
}
export declare class CreateHealthRecordDto {
    record_type: HealthRecordType;
    record_date: string;
    description?: string;
    clinic?: string;
    nextDueDate?: string;
}

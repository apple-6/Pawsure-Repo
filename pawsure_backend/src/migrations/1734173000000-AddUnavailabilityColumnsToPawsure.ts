import { MigrationInterface, QueryRunner, TableColumn } from 'typeorm';

export class AddUnavailabilityColumnsToPawsure1734173000000 implements MigrationInterface {
    public async up(queryRunner: QueryRunner): Promise<void> {
        // Add unavailable_dates column
        await queryRunner.addColumn(
            'sitters',
            new TableColumn({
                name: 'unavailable_dates',
                type: 'text[]',
                isArray: true,
                default: `ARRAY[]::text[]`,
                isNullable: false,
            }),
        );

        // Add unavailable_days column
        await queryRunner.addColumn(
            'sitters',
            new TableColumn({
                name: 'unavailable_days',
                type: 'text[]',
                isArray: true,
                default: `ARRAY[]::text[]`,
                isNullable: false,
            }),
        );
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        // Rollback: drop the columns
        await queryRunner.dropColumn('sitters', 'unavailable_dates');
        await queryRunner.dropColumn('sitters', 'unavailable_days');
    }
}
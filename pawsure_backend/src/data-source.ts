import 'dotenv/config';
import { DataSource } from 'typeorm';
import { ConfigService } from '@nestjs/config';
import { getTypeOrmConfig } from './config/typeorm.config';

// A helper to allow getTypeOrmConfig to work with process.env for CLI usage
const configService = new ConfigService(process.env);

const AppDataSource = new DataSource(getTypeOrmConfig(configService));

export default AppDataSource;

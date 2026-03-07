# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-15

### Added

- Spanner instance creation with regional and multi-region configurations
- Autoscaling configuration with CPU and storage utilization targets
- Fixed capacity provisioning via processing units or node count
- Database creation with DDL statement management
- CMEK encryption support for databases
- Point-in-time recovery via configurable version retention period
- PostgreSQL dialect support alongside Google Standard SQL
- Drop protection and deletion protection for databases
- Backup schedule management with cron expressions
- Backup retention period configuration
- Encrypted backup support with CMEK
- Instance-level IAM member bindings with conditional access
- Database-level IAM member bindings with conditional access
- Force destroy option for development instances
- Comprehensive input validation
- Basic, advanced, and complete usage examples

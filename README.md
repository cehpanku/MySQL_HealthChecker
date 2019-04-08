# MySQL HealthChecker

This project aims to collect the details of the MySQL Server running on *\*nix* Machines and save the details in DB_OS_Info.csv File.
The Script supports the following fields as of now & can be extended to support other fields also.

Field|Details
---|---
HostnameDBName|Hostname of the SQL Server
DBName|Table Name
DBSize|Table Size
DBCount|Total Tables
DBVersion|MySQL DB Version
DBPort|Database Port
DBMemory|Database Memory
DBPatchLevel|Database PatchLevel
DBMountTotalSize|Mount Point Size
DBMountUsedSize|Database Mount Size
DBMountFree|Free Space
LastSuccessfulBackup|LastBackup Date(Default:NA)
Replication-Mirroring|Replication(Default:NA)
HADR|High Avail & Disaster Recovery(Default:NA)
OSArch|Operating System Name
OSEd|OS Architecture
OSVersion|OS Version
CPU#|Number of CPU
RAMSize|RAM Size


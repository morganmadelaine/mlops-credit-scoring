<#
.SYNOPSIS
    Bootstrap ingestion: Kaggle -> local -> GCS -> BigQuery raw layer.

.DESCRIPTION
    Downloads the Home Credit Default Risk dataset, uploads it to GCS,
    and loads each CSV into the BigQuery raw dataset.
    This is a bootstrap runbook, not the production pipeline.

.EXAMPLE
    .\scripts\ingest_data.ps1
    .\scripts\ingest_data.ps1 -SkipDownload
#>

param(
    [string]$ProjectId = "credit-scoring-mlops-mm-001",
    [string]$Bucket    = "credit-scoring-mlops-mm-001-data",
    [string]$Dataset   = "credit_scoring_raw",
    [string]$DataDir   = "$env:USERPROFILE\data\home-credit",
    [switch]$SkipDownload
)

$ErrorActionPreference = "Stop"

#-----------------------------------------------
# Define variables & check context

$competition = "home-credit-default-risk"
$gcsPrefix   = "gs://$Bucket/raw"

# CSV file name -> BigQuery table name
$tables = @(
    @{ Csv = "application_train";     Table = "application_train" }
    @{ Csv = "application_test";      Table = "application_test" }
    @{ Csv = "bureau";                Table = "bureau" }
    @{ Csv = "bureau_balance";        Table = "bureau_balance" }
    @{ Csv = "credit_card_balance";   Table = "credit_card_balance" }
    @{ Csv = "installments_payments"; Table = "installments_payments" }
    @{ Csv = "POS_CASH_balance";      Table = "pos_cash_balance" }
    @{ Csv = "previous_application";  Table = "previous_application" }
)

Write-Host "=== Context check ===" -ForegroundColor Cyan
$current = gcloud config get-value project 2>$null
if ($current -ne $ProjectId) {
    throw "Active gcloud project is '$current', expected '$ProjectId'."
}

#-----------------------------------------------
# Download from Kaggle & Upload to GCS

if (-not $SkipDownload) {
    Write-Host "=== Downloading from Kaggle ===" -ForegroundColor Cyan
    New-Item -ItemType Directory -Force -Path $DataDir | Out-Null
    kaggle competitions download -c $competition -p $DataDir
    Expand-Archive -Path "$DataDir\$competition.zip" -DestinationPath $DataDir -Force
}

Write-Host "=== Uploading to GCS ===" -ForegroundColor Cyan
gcloud storage cp "$DataDir\*.csv" "$gcsPrefix/"

#-----------------------------------------------

Write-Host "=== Loading into BigQuery ===" -ForegroundColor Cyan
foreach ($t in $tables) {
    Write-Host "  -> $($t.Table)" -ForegroundColor Yellow
    $bqArgs = @(
        "--source_format=CSV"
        "--autodetect"
        "--skip_leading_rows=1"
        "--replace"
        "$Dataset.$($t.Table)"
        "$gcsPrefix/$($t.Csv).csv"
    )
    bq load @bqArgs
}

Write-Host "=== Verification ===" -ForegroundColor Cyan
$query = "SELECT table_id, row_count FROM $Dataset.__TABLES__ ORDER BY row_count DESC"
bq query --use_legacy_sql=false $query

Write-Host "=== Done ===" -ForegroundColor Green

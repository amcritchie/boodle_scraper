# HEARTBEAT.md

# Heartbeat checks for stuck tasks every ~30 minutes

## Task Monitoring
- Check for "active" tasks stuck > 2 minutes → restart them
- Check for "idle" tasks → attempt to process

## How to use
Tasks are created automatically by ArticleIngestionService.ingest(url:)
- idle = waiting to be picked up
- active = currently processing  
- completed = finished successfully
- failed = error occurred

@echo off
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0sync-agents.ps1" %*

# Gt-PsyCabinet

A psychology cabinet management tool built with [Glamorous Toolkit](https://gtoolkit.com/).

Manages patients, sessions, receipts, and finances for a psychology practice in Luxembourg, with built-in support for the CNS reimbursement code system (SP01/SP02/SP03).

## Features

- **Patient management** — add patients manually or import from CSV
- **Session tracking** — record and cancel sessions with automatic CNS code selection
- **Receipt generation** — generate receipts for uncovered sessions, export to DOCX/PDF
- **Event sourcing** — all actions are persisted as events to a STON log file and can be replayed
- **GT views** — rich inspector views for patients, sessions, receipts, and financial overviews

## Installation

In a Glamorous Toolkit playground:

```smalltalk
Metacello new
    repository: 'github://syarra/gt-psycabinet:master/src';
    baseline: 'GtPsyCabinet';
    load.
```

## Usage

See the Lepiter page **"How to use CbCabinetManager"** included in this repository for interactive documentation with runnable examples.

Quick start:

```smalltalk
cabinet := CbCabinetManager new.
cabinet addPatientFirstName: 'Claire' lastName: 'Dupont' matricule: '1985010112345' code: 1.

patient := cabinet patients first.
patient recordSessionOn: Date today.
patient generateReceiptForUncoveredSessions: Date today.
```

## Running examples

All tests are written as `gtExample` methods in the `Gt-PsyCabinet-Examples` package:

```smalltalk
CbCabinetManagerExamples new exampleCabinetWithPatients.
```

# AndHealth Onsite — Analytics Engineer Project

## My Approach and Key Modeling Decisions
- Built clean, well-tested **staging models** for each source table:  
  `appointments`, `visits`, `providers`, `patients`, `visit_providers`, `survey`, and `date_dim`.  
- Added **data tests** for primary keys, relationships, and accepted values to establish a trusted foundation.  
- Created a **macro to normalize clinic names** (e.g., “Downtown Clinic” vs “downtown”) for consistent reporting.  
- Used `select distinct` to **deduplicate patients** (`P0124` appeared twice).  
- Joined `visits`, `appointments`, and `providers` to define key metrics such as:  
  - Appointment completion, cancellation, and reschedule rates  
  - Average visit duration and quarterly clinic volume  
  - Early prototype of provider utilization (used minutes ÷ available minutes)
- Designed the dbt project with a **layered structure**:  
  - *Staging* → cleaned raw data  
  - *Intermediate* → business logic and joins  
  - *Marts* → aggregated, stakeholder-ready metrics  
- Kept transformations **modular and documented** to support scalability and ease of maintenance.

---

## The Semantic Layer
- The **semantic layer** defines and governs shared business metrics — ensuring consistent definitions across dashboards, teams, and future NLQ/LLM tools.  
- It serves as the **bridge between engineering precision and business clarity**.  
- In this project, it means defining reusable entities (`clinic`, `provider`, `patient`) and metrics such as:  
  - `appointment_completion_rate`  
  - `clinic_utilization`  
  - `avg_visit_duration`  
- Ongoing maintenance includes:  
  - Version-controlling and documenting metric logic in dbt  
  - Adding tests to catch upstream data or logic breaks  
  - Partnering with product and clinical ops teams to align on metric definitions  

---

## Data Quality Issues and Assumptions
- **Clinic names** → normalized via macro for consistent aggregation  
- **Duplicate patients** → resolved using `select distinct`  
- **Missing provider IDs (24–30)** → left null; would investigate in source system  
- **Appointments without visits (161)** → potential scheduling or EMR sync gap  
- **Inactive clinics (2)** → may represent missing data or newly created sites  
- **Reschedules** → treated as their own category; could later link to original appointment to assess scheduling efficiency  

---

## What I’d Do Next with More Time
- **Operational modeling**  
  - Refine provider utilization by incorporating clinic capacity or scheduling data  
  - Build time-based and slot-based utilization metrics at the clinic level  
- **Patient retention analytics**  
  - Correlate survey satisfaction scores with appointment completion and attrition  
  - Identify patient segments at risk of dropping out based on demographics or payer type  
- **Metric governance**  
  - Formalize the semantic layer using dbt metrics or a framework like Cube / MetricFlow  
  - Document and expose consistent metric definitions for BI and LLM-driven exploration  
- **Enablement**  
  - Create Looker or Looker Studio dashboards showing:  
    - Clinic performance over time  
    - Provider utilization and appointment mix  
    - Appointment funnel and completion trends  

---


this repo contains the dbt for this onsite assignment

working assumptions: 
i originally assumed that visits would have all of the locations. but i changed that assumption to that providers would have all the clinic locations 

steps: 
built staging models and tests on primary keys, accepted values, relationships. discovered the following about the data in addition to the ones listed - 
Data quality issues discovered or previous noted in the project. normalized: 
- clinic name inconsistencies clean up using macro 
- P0124 was loaded twice in patients, resolved with select distinct in staging layer

Data quality issues / questions, not handled:
- in providers - missing provider_ids 24-30
- 161 completed appointments does not have associated visits, need to understand why and think about what metrics we care about surrounding appointments
- 2 clinics aren't being utilized at all or no data from them?

Definitions
- rescheduled appointments is a very interesting data point, and can potentially provide a lot of value if we had more data collected. if an appointment was cancelled or rescheduled, when was it rescheduled/cancelled relative to the appointment time? were we later able to fill that same appointment time? this could contribute to poorer clinic utilization. Could recommend a cancellation fee if within a period of time, or recommend reminder messages. For now, i'd keep rescheduled as its own definition until more data point can be gathered to break appointments out into different models serving metrics that could help increase appointment completion rate. 

goals - 
- get people into see doctors regularly. once a quarter could be gold standard. 
- clinics and doctors are well utilized to be able to serve 5 doctors a day 

Some examples of more data that could be gathered: 
- capacity for each clinic - how many visits can a clinic fit in a day, how many primary providers can work there 
- appointments data points - are appointments rescheduled/cancelled through phone or web? record the time of every appointment event, reason. can understand how to improve appointment completion rate and utilization rate 



if i had more time:
- have a more sophisticated understanding of appointments/visits and how they affect topline clinic performance
- patient attrition evaluation, how can we retain patients and have them come for check ups quarterly. do survey scores correlate with their visit rate/appointment completion rate, would a negative survey score (less than 3) affect their next likelihood of getting to their next appointment. do other attributes affect patient attrition - how they pay, age range, location, etc.. 
- provider analysis. survey results by provider, evaluate performance. what could contribute to survey scores for providers? are certain specialties more in demand than others, do specialities have more or less cancelled/no show appointments?



Andhealth onsite 

AndHealth Analytics Engineer Project - Synthetic Dataset (v2)

Additions in v2:
- providers.csv with specific counts: 3 Rheumatologists, 5 Dermatologists, 5 Nurse Practitioners, 10 Clinical Pharmacists.
- visit_providers.csv mapping visits to providers with roles (Primary/Secondary). ~13% of visits are multi-provider (often specialist + pharmacist).
- visits.csv now includes visit_duration_minutes and modality (Telehealth/In-Person). ~60% Telehealth overall.
- Each provider can work across up to 5 clinics; providers.csv 'home_clinic' shows one assigned site.
- Appointments reconciled to valid provider_id set if any were outside of the defined provider list.

File row counts:
- patients.csv: 801
- appointments.csv: 3084
- visits.csv: 1844
- visit_providers.csv: 2102
- providers.csv: 23
- survey.csv: 1198
- date_dim.csv: 365

Notes for candidates:
- Clinics have naming inconsistencies in appointments/visits (e.g., 'Downtown Clinic', 'downtown clinic', 'Downtown'). Consider normalization layer.
- Some appointments are 'rescheduled' with a follow-up row. Define how reschedules should factor into metrics.
- A tiny % of visits may have missing provider_id; these were assigned to valid providers here.
- New vs. follow-up: First visit for a patient is likely 60 minutes; others ~30 minutes (±5 min noise).
- Telehealth visits are associated with a clinic for attribution; a small subset use 'Telehealth Hub' as location.





📘 AndHealth Analytics Engineer Project
Thank you for taking the time to participate in our Analytics Engineer project.
At AndHealth, we’re on a mission to make world-class specialty care accessible and affordable to everyone. Our Analytics team plays a key role in that mission by helping the entire organization ask and answer questions from data — easily, confidently, and independently.
This project is designed to mirror the kind of work you’d take on in the role: building a small, meaningful data experience that bridges data modeling, semantic design, and usability.
We’re excited to see how you think, structure your work, and communicate your decisions.

Project Overview
The project happens in two parts:
Part 1: Homework Build (3-4 hours, before project day)
You’ll receive a small synthetic dataset that represents a simplified version of our healthcare environment.
Your goal is to model and document a lightweight semantic layer — that is, to define clear, reusable metrics and relationships — and to demonstrate a simple self-service data experience in Looker (preferred) or another BI tool.
Please:
	•	Model and join the data into something explorable.
	•	Define 2–3 reusable, governed metrics — for example (you can choose others!):
	•	Provider Utilization
	•	No-Show Rate
	•	Average Satisfaction Score
	•	Build a simple Explore or dashboard that could help an operations leader answer:How are we performing across our clinics and payer types this quarter — and what’s driving the differences? Think about this like a clinic operations leader, you need to know what is working well, what's not, and what are the hidden opportunities to improve.
	•	Prepare a brief write-up (1 page max) describing:
	•	Your approach and key modeling decisions
	•	What the semantic layer means to you and what work goes into building and maintaining it
	•	Any data quality issues or assumptions you encountered
	•	What you’d do next with more time
Please spend no more than ~4 hours on this part.
When complete, share:
	•	A Looker link or screenshots of your Explore/dashboard
	•	Your one-page summary document
We’ll review this together during the live session.


Part 2: Project Day (2 hours live)
We’ll have about two-hours in-person to spend on:
	•	Walk us through your project – explain how you modeled the data, joined tables, and defined metrics.
	•	Teach us about the semantic layer — in your own words:
	•	What is it?
	•	What types of work go into it?
	•	Why does it matter for self-service analytics?
	•	Collaborate on a small change or enhancement. Feel free to bring an idea, or spend time asking questions of the team to arrive at something valuable.
	•	Reflect on how you’d scale or productionize your approach at AndHealth.
We’ll keep it conversational and hands-on.

📦 Dataset
Download the dataset here: 👉 andhealth_analytics_engineer_dataset_v2.zip
Inside the ZIP file:
File
Description
patients.csv
Patient demographics and payer info
appointments.csv
All scheduled appointments and outcomes
visits.csv
Completed visits (with duration & modality)
visit_providers.csv
Many-to-many mapping between visits and providers
providers.csv
Provider list (Rheumatologists, Dermatologists, NPs, Clinical Pharmacists)
survey.csv
Post-visit satisfaction surveys
date_dim.csv
Date dimension for grouping by month/quarter
README.txt
Dataset notes and known quirks

The dataset includes realistic imperfections — for example, you may notice inconsistent clinic names or missing data in some records. Feel free to fix, document, or work around these however you see fit. Your approach is part of what we’ll discuss.


Deliverables Checklist
Please send before project day:
	•	A Looker link or screenshots of your Explore/dashboard
	•	2–3 governed metrics with clear definitions
	•	A short summary document (about 1 page) including:
	•	Your modeling approach
	•	What a semantic layer means and what work it entails
	•	Any assumptions or challenges
	•	Next steps if you had more time
Be ready during the live session to:
	•	Walk us through your work
	•	Teach us about your semantic layer and decision process
	•	Make one small enhancement or adjustment collaboratively

Tone & Expectations
This isn’t about perfection — it’s about how you think.We value clarity over complexity and curiosity over polish.
If something’s unclear, tell us how you’d clarify it.If scope was too large given the allotted time, tell us why and how you narrowed it.If something’s messy, explain how you’d fix it.If you have a better idea, show us.
We’re excited to learn from you!




### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices

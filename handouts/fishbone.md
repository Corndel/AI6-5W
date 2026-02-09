# Handout — Fishbone for “Why didn’t it scale?”

Use this when people are guessing.

## Effect (head of the fish)
**Pipeline slow / failing during traffic spike**

## Bones (main categories)
1) **Limits**
- reserved concurrency too low
- quotas
- rate limits

2) **Resources**
- memory too low
- CPU too low
- cold start overhead

3) **Dependencies**
- external API slow
- downstream service throttling
- network latency

4) **Data / Input**
- payload too big
- schema mismatch
- unexpected distribution shift

## How to use (fast)
- Put one piece of evidence on the fish first (metric/log/event)
- Only then add causes under the matching bone
- Pick one “first action” that is safe and reversible

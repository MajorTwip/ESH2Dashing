# ESH2Dashing
A simple SSE-client to relayfrom ESH (OpenHAB2) to Dashing

A quick and dirty small script that subscribes to the SSE-channel (normally  http://localhost:8080/rest/events) and produces for every event a HTTP-GET to the Rest-API from dashing to update the tiles. 

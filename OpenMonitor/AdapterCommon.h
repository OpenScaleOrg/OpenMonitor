#pragma once
#include "Common.h"

// Stores information about a network connection
struct NetWorkConection
{
	int index{};			// Index of the connection in MIB_IFTABLE
	string description;		// Connection description (retrieved from GetAdapterInfo)
	string description_2;	// Connection description (retrieved from GetIfTable)
	unsigned int in_bytes;	// Bytes received at the start time
	unsigned int out_bytes;	// Bytes sent at the start time
	wstring ip_address{ L"-.-.-.-" };	// IP address
	wstring subnet_mask{ L"-.-.-.-" };	// Subnet mask
	wstring default_gateway{ L"-.-.-.-" };	// Default gateway
};

class CAdapterCommon
{
public:
	CAdapterCommon();
	~CAdapterCommon();

	// Retrieves the adapter list along with IP address, subnet mask, and default gateway information for each adapter
	static void GetAdapterInfo(vector<NetWorkConection>& adapters);

	// Refreshes the IP address, subnet mask, and default gateway information in the adapter list
	static void RefreshIpAddress(vector<NetWorkConection>& adapters);

	// Retrieves MIB_IFTABLE index and initial bytes received/sent information for each connection in the adapter list
	static void GetIfTableInfo(vector<NetWorkConection>& adapters, MIB_IFTABLE* pIfTable);

	// Directly adds all connections from MIB_IFTABLE into the adapters container
	static void GetAllIfTableInfo(vector<NetWorkConection>& adapters, MIB_IFTABLE* pIfTable);
private:
	// Given a connection description, checks whether it exists in the IfTable list; returns -1 if not found
	static int FindConnectionInIfTable(string connection, MIB_IFTABLE* pIfTable);

	// Given a connection description, checks whether it exists in the IfTable list using fuzzy matching; returns -1 if not found, only requires partial match
	static int FindConnectionInIfTableFuzzy(string connection, MIB_IFTABLE* pIfTable);
};


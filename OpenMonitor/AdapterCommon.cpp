#include "stdafx.h"
#include "AdapterCommon.h"


CAdapterCommon::CAdapterCommon()
{
}


CAdapterCommon::~CAdapterCommon()
{
}

void CAdapterCommon::GetAdapterInfo(vector<NetWorkConection>& adapters)
{
	adapters.clear();
	PIP_ADAPTER_INFO pIpAdapterInfo = (PIP_ADAPTER_INFO)new BYTE[sizeof(IP_ADAPTER_INFO)];		//PIP_ADAPTER_INFO struct pointer to store local network adapter info
	unsigned long stSize = sizeof(IP_ADAPTER_INFO);		//Get struct size, used as parameter for GetAdaptersInfo
	int nRel = GetAdaptersInfo(pIpAdapterInfo, &stSize);	//Call GetAdaptersInfo to fill the pIpAdapterInfo pointer; stSize is both an input and output parameter

	if (ERROR_BUFFER_OVERFLOW == nRel)
	{
		//If the function returns ERROR_BUFFER_OVERFLOW,
		//it means the memory passed to GetAdaptersInfo is insufficient; stSize is updated to indicate the required size.
		//This is why stSize serves as both an input and an output parameter.
		delete[] (BYTE*)pIpAdapterInfo;	//Free the original memory
		pIpAdapterInfo = (PIP_ADAPTER_INFO)new BYTE[stSize];	//Reallocate memory to store all adapter info
		nRel = GetAdaptersInfo(pIpAdapterInfo, &stSize);		//Call GetAdaptersInfo again to fill pIpAdapterInfo
	}

	PIP_ADAPTER_INFO pIpAdapterInfoHead = pIpAdapterInfo;	//Save the address of the first element in the pIpAdapterInfo linked list
	if (ERROR_SUCCESS == nRel)
	{
		while (pIpAdapterInfo)
		{
			NetWorkConection connection;
			connection.description = pIpAdapterInfo->Description;
			connection.ip_address = CCommon::StrToUnicode(pIpAdapterInfo->IpAddressList.IpAddress.String);
			connection.subnet_mask = CCommon::StrToUnicode(pIpAdapterInfo->IpAddressList.IpMask.String);
			connection.default_gateway = CCommon::StrToUnicode(pIpAdapterInfo->GatewayList.IpAddress.String);

			adapters.push_back(connection);
			pIpAdapterInfo = pIpAdapterInfo->Next;
		}
	}
	//Free memory
	if (pIpAdapterInfoHead)
	{
		delete[] (BYTE*)pIpAdapterInfoHead;
	}
	if (adapters.empty())
	{
		NetWorkConection connection{};
		connection.description = CCommon::UnicodeToStr(CCommon::LoadText(L"<", IDS_NO_CONNECTION, L">"));
		adapters.push_back(connection);
	}
}

void CAdapterCommon::RefreshIpAddress(vector<NetWorkConection>& adapters)
{
	vector<NetWorkConection> adapters_tmp;
	GetAdapterInfo(adapters_tmp);
	for (const auto& adapter_tmp : adapters_tmp)
	{
		for (auto& adapter : adapters)
		{
			if (adapter_tmp.description == adapter.description)
			{
				adapter.ip_address = adapter_tmp.ip_address;
				adapter.subnet_mask = adapter_tmp.subnet_mask;
				adapter.default_gateway = adapter_tmp.default_gateway;
			}
		}
	}
}

void CAdapterCommon::GetIfTableInfo(vector<NetWorkConection>& adapters, MIB_IFTABLE* pIfTable)
{
	//Search for each connection in IfTable sequentially
	for (size_t i{}; i < adapters.size(); i++)
	{
		if (adapters[i].description.empty())
			continue;
		int index;
		index = FindConnectionInIfTable(adapters[i].description, pIfTable);
		if (index == -1)		//If exact match fails, try fuzzy matching
			index = FindConnectionInIfTableFuzzy(adapters[i].description, pIfTable);
		//if (index != -1)
		//{
		adapters[i].index = index;
		adapters[i].in_bytes = pIfTable->table[index].dwInOctets;
		adapters[i].out_bytes = pIfTable->table[index].dwOutOctets;
		adapters[i].description_2 = (const char*)pIfTable->table[index].bDescr;
		//}
	}
}

void CAdapterCommon::GetAllIfTableInfo(vector<NetWorkConection>& adapters, MIB_IFTABLE * pIfTable)
{
	vector<NetWorkConection> adapters_tmp;
	GetAdapterInfo(adapters_tmp);		//Get IP addresses
	adapters.clear();
	for (size_t i{}; i < pIfTable->dwNumEntries; i++)
	{
		NetWorkConection connection;
		connection.description = connection.description_2 = (const char*)pIfTable->table[i].bDescr;
		connection.index = i;
		connection.in_bytes = pIfTable->table[i].dwInOctets;
		connection.out_bytes = pIfTable->table[i].dwOutOctets;
		for (size_t j{}; j < adapters_tmp.size(); j++)
		{
			if (connection.description.find(adapters_tmp[j].description) != string::npos)
			{
				connection.ip_address = adapters_tmp[j].ip_address;
				connection.subnet_mask = adapters_tmp[j].subnet_mask;
				connection.default_gateway = adapters_tmp[j].default_gateway;
				break;
			}
		}
		adapters.push_back(connection);
	}
}

int CAdapterCommon::FindConnectionInIfTable(string connection, MIB_IFTABLE* pIfTable)
{
	for (size_t i{}; i < pIfTable->dwNumEntries; i++)
	{
		string descr = (const char*)pIfTable->table[i].bDescr;
		if (descr == connection)
			return i;
	}
	return -1;
}

int CAdapterCommon::FindConnectionInIfTableFuzzy(string connection, MIB_IFTABLE* pIfTable)
{
	for (size_t i{}; i < pIfTable->dwNumEntries; i++)
	{
		string descr = (const char*)pIfTable->table[i].bDescr;
		size_t index;
		//Search for the shorter string within the longer string
		if (descr.size() >= connection.size())
			index = descr.find(connection);
		else
			index = connection.find(descr);
		if (index != wstring::npos)
			return i;
	}
	//If still not found, use a string similarity algorithm
	double max_degree{};
	int best_index{};
	for (size_t i{}; i < pIfTable->dwNumEntries; i++)
	{
		string descr = (const char*)pIfTable->table[i].bDescr;
		double degree = CCommon::StringSimilarDegree_LD(descr, connection);
		if (degree > max_degree)
		{
			max_degree = degree;
			best_index = i;
		}
	}
	return best_index;
}

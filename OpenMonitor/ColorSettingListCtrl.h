#pragma once
#include "afxcmn.h"
#include "DrawCommon.h"
class CColorSettingListCtrl :
	public CListCtrl
{
DECLARE_DYNAMIC(CColorSettingListCtrl)
public:
	CColorSettingListCtrl();
	~CColorSettingListCtrl();

    void SetItemColor(int row, int col, COLORREF color);
    COLORREF GetItemColor(int row, int col);
	void SetDrawItemRangMargin(int margin) { m_margin = margin; }			// Set the margin between the drawn rectangle and the cell border; the larger the value, the thinner the drawn rectangle — it cannot exceed half the cell border width

protected:
	int m_margin{};
	std::map<int, std::map<int, COLORREF>> m_colors;	//���ڱ���ÿһ��ÿһ�е���ɫ

	DECLARE_MESSAGE_MAP()
	afx_msg void OnNMCustomdraw(NMHDR *pNMHDR, LRESULT *pResult);
};


#pragma once
#include "LinkStatic.h"
#include "BaseDialog.h"

// CAboutDlg dialog used for the application "About" menu item

class CAboutDlg : public CBaseDialog
{
public:
    CAboutDlg();

    // Dialog data
#ifdef AFX_DESIGN_TIME
    enum { IDD = IDD_ABOUTBOX };
#endif

protected:
    CLinkStatic m_mail;             // "Contact Author" hyperlink
    CLinkStatic m_acknowledgement;  // "Acknowledgements" hyperlink
    CLinkStatic m_github;           // "GitHub" hyperlink
    CLinkStatic m_license;          // "Open Source License" hyperlink
    CToolTipCtrl m_tool_tip;            // Tooltip shown when mouse hovers
    CLinkStatic m_translator_static;
    CLinkStatic m_openhardwaremonitor_link;
    CLinkStatic m_tinyxml2_link;
    CLinkStatic m_musicplayer2_link;
    CLinkStatic m_simplenotepad_link;

    CBitmap m_about_pic;

    virtual void DoDataExchange(CDataExchange* pDX);    // DDX/DDV support
    CString GetDonateList();        // Load donor list from resource file
    virtual CString GetDialogName() const override;
    virtual bool InitializeControls() override;
    CRect CalculatePicRect();       // Calculate the position of the image

    // Implementation
protected:
    DECLARE_MESSAGE_MAP()
public:
    virtual BOOL OnInitDialog();
    virtual BOOL PreTranslateMessage(MSG* pMsg);
    //  afx_msg void OnStnClickedStaticDonate();
protected:
    afx_msg LRESULT OnLinkClicked(WPARAM wParam, LPARAM lParam);
public:
    afx_msg void OnPaint();
    afx_msg BOOL OnEraseBkgnd(CDC* pDC);
    afx_msg HBRUSH OnCtlColor(CDC* pDC, CWnd* pWnd, UINT nCtlColor);
};

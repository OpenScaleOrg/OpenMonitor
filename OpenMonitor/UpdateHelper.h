#pragma once
class CUpdateHelper
{
public:
    CUpdateHelper();
    ~CUpdateHelper();

    bool CheckForUpdate();

    const std::wstring& GetVersion() const;
    const std::wstring& GetLink() const;
    const std::wstring& GetLink64() const;
    const std::wstring& GetLinkArm64ec() const;
    const std::wstring& GetLinkAppInstaller() const;
    const std::wstring& GetContentsEn() const;
    bool IsRowData();

private:
    void ParseUpdateInfo(wstring version_info);

private:
    std::wstring m_version;
    std::wstring m_link;
    std::wstring m_link64;
    std::wstring m_link_arm64ec;
    std::wstring m_link_appinstaller;
    std::wstring m_contents_en;
    bool m_row_data{ true };
};

unit IPHelper;

interface

uses Windows;

const
  ERROR_SUCCESS = 0;
  ERROR_BUFFER_OVERFLOW = 111;
  MAX_ADAPTER_NAME_LENGTH = 256;
  MAX_ADAPTER_DESCRIPTION_LENGTH = 128;
  MAX_ADAPTER_ADDRESS_LENGTH = 8;

type
  TIPAddressString = record
    _String: array [1..16] of Char;
  end;
  TIPMaskString = TIPAddressString;

  PIPAddrString = ^TIPAddrString;
  TIPAddrString = record
    Next: PIPAddrString;
    IpAddress: TIPAddressString;
    IpMask: TIPAddressString;
    Context: DWORD;
  end;

  PIPAdapterInfo = ^TIPAdapterInfo;
  TIPAdapterInfo = record
    Next: PIPAdapterInfo;
    ComboIndex: DWORD;
    AdapterName: array [1..MAX_ADAPTER_NAME_LENGTH + 4] of Char;
    Description: array [1..MAX_ADAPTER_DESCRIPTION_LENGTH + 4] of Char;
    AddressLength: UINT;
    Address: array [1..MAX_ADAPTER_ADDRESS_LENGTH] of Byte;
    Index: DWORD;
    _Type: UINT;
    DhcpEnabled: UINT;
    CurrentIpAddress: PIPAddrString;
    IpAddressList: TIPAddrString;
    GatewayList: TIPAddrString;
    DhcpServer: TIPAddrString;
    HaveWins: BOOL;
    PrimaryWinsServer: TIPAddrString;
    SecondaryWinsServer: TIPAddrString;
    LeaseObtained: Longint;
    LeaseExpires: Longint;
  end;

function GetAdaptersInfo(pAdapterInfo: Pointer; pOutBufLen: PULONG): DWORD; StdCall; External 'iphlpapi.dll';

implementation



end.

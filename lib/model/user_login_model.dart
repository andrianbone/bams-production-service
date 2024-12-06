class UserLogin {
  String? status;
  Session? session;

  UserLogin({this.status, this.session});

  UserLogin.fromJson(Map<String, dynamic> json) {
    status = json['status'];
    session =
        json['session'] != null ? Session.fromJson(json['session']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['status'] = status;
    if (session != null) {
      data['session'] = session?.toJson();
    }
    return data;
  }
}

class Session {
  User? user;

  Session({this.user});

  Session.fromJson(Map<String, dynamic> json) {
    user = json['User'] != null ? User.fromJson(json['User']) : null;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (user != null) {
      data['User'] = user?.toJson();
    }
    return data;
  }
}

class User {
  UserSub? usersub;
  Organization? organization;
  String? package;

  User({this.usersub, this.package});

  User.fromJson(Map<String, dynamic> json) {
    usersub = json['User'] != null ? UserSub.fromJson(json['User']) : null;
    organization = json['Organization'] != null
        ? Organization.fromJson(json['Organization'])
        : null;
    package = json['Package'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (usersub != null) {
      data['User'] = usersub!.toJson();
    }
    if (organization != null) {
      data['Organization'] = organization!.toJson();
    }
    data['Package'] = package;
    return data;
  }
}

class UserSub {
  String? uSERID;
  String? uSERNAME;
  String? uSEREMAIL;
  String? uSERLOGIN;
  String? oRGID;
  String? oRGSUBID;
  String? bLOCKED;
  String? nONACTIVEDATE;
  String? uPDATEUSER;
  String? uPDATEDATE;
  String? nONLDAPUSER;
  String? uSERPASSWORD;
  String? uSERCODE;
  String? uSERMENU;
  String? cREWID;
  String? lASTTIMELOGIN;
  String? gROUPMENU;
  String? iSACTIVE;
  String? nOTES;
  String? cREWAREA;
  String? rESPONSIBILITYORG;
  String? pROGRAMUSAGE;
  String? uSEREMAILOLD;

  UserSub(
      {this.uSERID,
      this.uSERNAME,
      this.uSEREMAIL,
      this.uSERLOGIN,
      this.oRGID,
      this.oRGSUBID,
      this.bLOCKED,
      this.nONACTIVEDATE,
      this.uPDATEUSER,
      this.uPDATEDATE,
      this.nONLDAPUSER,
      this.uSERPASSWORD,
      this.uSERCODE,
      this.uSERMENU,
      this.cREWID,
      this.lASTTIMELOGIN,
      this.gROUPMENU,
      this.iSACTIVE,
      this.nOTES,
      this.cREWAREA,
      this.rESPONSIBILITYORG,
      this.pROGRAMUSAGE,
      this.uSEREMAILOLD});

  UserSub.fromJson(Map<String, dynamic> json) {
    uSERID = json['USER_ID'] ?? "";
    uSERNAME = json['USER_NAME'] ?? "";
    uSEREMAIL = json['USER_EMAIL'] ?? "";
    uSERLOGIN = json['USER_LOGIN'] ?? "";
    oRGID = json['ORG_ID'] ?? "";
    oRGSUBID = json['ORG_SUB_ID'] ?? "";
    bLOCKED = json['BLOCKED'] ?? "";
    nONACTIVEDATE = json['NON_ACTIVE_DATE'] ?? "";
    uPDATEUSER = json['UPDATE_USER'] ?? "";
    uPDATEDATE = json['UPDATE_DATE'] ?? "";
    nONLDAPUSER = json['NON_LDAP_USER'] ?? "";
    uSERPASSWORD = json['USER_PASSWORD'] ?? "";
    uSERCODE = json['USER_CODE'] ?? "";
    uSERMENU = json['USER_MENU'] ?? "";
    cREWID = json['CREW_ID'] ?? "";
    lASTTIMELOGIN = json['LAST_TIME_LOGIN'] ?? "";
    gROUPMENU = json['GROUP_MENU'] ?? "";
    iSACTIVE = json['IS_ACTIVE'] ?? "";
    nOTES = json['NOTES'] ?? "";
    cREWAREA = json['CREW_AREA'] ?? "";
    rESPONSIBILITYORG = json['RESPONSIBILITY_ORG'] ?? "";
    pROGRAMUSAGE = json['PROGRAM_USAGE'] ?? "";
    uSEREMAILOLD = json['USER_EMAIL_OLD'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['USER_ID'] = uSERID;
    data['USER_NAME'] = uSERNAME;
    data['USER_EMAIL'] = uSEREMAIL;
    data['USER_LOGIN'] = uSERLOGIN;
    data['ORG_ID'] = oRGID;
    data['ORG_SUB_ID'] = oRGSUBID;
    data['BLOCKED'] = bLOCKED;
    data['NON_ACTIVE_DATE'] = nONACTIVEDATE;
    data['UPDATE_USER'] = uPDATEUSER;
    data['UPDATE_DATE'] = uPDATEDATE;
    data['NON_LDAP_USER'] = nONLDAPUSER;
    data['USER_PASSWORD'] = uSERPASSWORD;
    data['USER_CODE'] = uSERCODE;
    data['USER_MENU'] = uSERMENU;
    data['CREW_ID'] = cREWID;
    data['LAST_TIME_LOGIN'] = lASTTIMELOGIN;
    data['GROUP_MENU'] = gROUPMENU;
    data['IS_ACTIVE'] = iSACTIVE;
    data['NOTES'] = nOTES;
    data['CREW_AREA'] = cREWAREA;
    data['RESPONSIBILITY_ORG'] = rESPONSIBILITYORG;
    data['PROGRAM_USAGE'] = pROGRAMUSAGE;
    data['USER_EMAIL_OLD'] = uSEREMAILOLD;
    return data;
  }
}

class Organization {
  String? oRGID;
  String? oRGNAME;
  String? oRGDOMAIN;
  String? oRGCODE;
  String? oRGOU;
  String? uPDATEUSER;
  String? uPDATEDATE;
  String? lOGINFLAG;
  String? tBUFLAG;
  String? oRGLONGNAME;
  String? hCMORGID;
  String? oRGFONTCOLOR;
  String? oRGCOLOR;
  String? iTEMREPORTFLAG;
  String? oRGACTIVEFLAG;
  String? oRGAREA;

  Organization(
      {this.oRGID,
      this.oRGNAME,
      this.oRGDOMAIN,
      this.oRGCODE,
      this.oRGOU,
      this.uPDATEUSER,
      this.uPDATEDATE,
      this.lOGINFLAG,
      this.tBUFLAG,
      this.oRGLONGNAME,
      this.hCMORGID,
      this.oRGFONTCOLOR,
      this.oRGCOLOR,
      this.iTEMREPORTFLAG,
      this.oRGACTIVEFLAG,
      this.oRGAREA});

  Organization.fromJson(Map<String, dynamic> json) {
    oRGID = json['ORG_ID'] ?? "";
    oRGNAME = json['ORG_NAME'] ?? "";
    oRGDOMAIN = json['ORG_DOMAIN'] ?? "";
    oRGCODE = json['ORG_CODE'] ?? "";
    oRGOU = json['ORG_OU'] ?? "";
    uPDATEUSER = json['UPDATE_USER'] ?? "";
    uPDATEDATE = json['UPDATE_DATE'] ?? "";
    lOGINFLAG = json['LOGIN_FLAG'] ?? "";
    tBUFLAG = json['TBU_FLAG'] ?? "";
    oRGLONGNAME = json['ORG_LONG_NAME'] ?? "";
    hCMORGID = json['HCM_ORG_ID'] ?? "";
    oRGFONTCOLOR = json['ORG_FONT_COLOR'] ?? "";
    oRGCOLOR = json['ORG_COLOR'] ?? "";
    iTEMREPORTFLAG = json['ITEM_REPORT_FLAG'] ?? "";
    oRGACTIVEFLAG = json['ORG_ACTIVE_FLAG'] ?? "";
    oRGAREA = json['ORG_AREA'] ?? "";
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['ORG_ID'] = oRGID;
    data['ORG_NAME'] = oRGNAME;
    data['ORG_DOMAIN'] = oRGDOMAIN;
    data['ORG_CODE'] = oRGCODE;
    data['ORG_OU'] = oRGOU;
    data['UPDATE_USER'] = uPDATEUSER;
    data['UPDATE_DATE'] = uPDATEDATE;
    data['LOGIN_FLAG'] = lOGINFLAG;
    data['TBU_FLAG'] = tBUFLAG;
    data['ORG_LONG_NAME'] = oRGLONGNAME;
    data['HCM_ORG_ID'] = hCMORGID;
    data['ORG_FONT_COLOR'] = oRGFONTCOLOR;
    data['ORG_COLOR'] = oRGCOLOR;
    data['ITEM_REPORT_FLAG'] = iTEMREPORTFLAG;
    data['ORG_ACTIVE_FLAG'] = oRGACTIVEFLAG;
    data['ORG_AREA'] = oRGAREA;
    return data;
  }
}

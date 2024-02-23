/// This enum represents manufacturers of cards along with their registered numbers.
///
/// The data for this enum is sourced from the "Register of IC Manufacturers" by ISO/IEC JTC 1/SC 17,
/// dated March 28, 2023. You can find more information about this register at the following link:
///
/// https://www.iso.org/committee/45144.html
enum CardManufacturer {
  Motorola(
    id: 0x01,
    company: 'Motorola',
    country: 'UK',
  ),
  STMicroelectronics(
    id: 0x02,
    company: 'STMicroelectronics SA',
    country: 'France',
  ),
  HitachiLtd(
    id: 0x03,
    company: 'Hitachi, Ltd',
    country: 'Japan',
  ),
  NXPSemiconductors(
    id: 0x04,
    company: 'NXP Semiconductors',
    country: 'Germany',
  ),
  InfineonTechnologies(
    id: 0x05,
    company: 'Infineon Technologies AG',
    country: 'Germany',
  ),
  Cylink(
    id: 0x06,
    company: 'Cylink',
    country: 'USA',
  ),
  TexasInstrument(
    id: 0x07,
    company: 'Texas Instrument',
    country: 'France',
  ),
  Fujitsu(
    id: 0x08,
    company: 'Fujitsu Limited',
    country: 'Japan',
  ),
  MatsushitaElectronicsSemiconductor(
    id: 0x09,
    company: 'Matsushita Electronics Corporation, Semiconductor Company',
    country: 'Japan',
  ),
  NEC(
    id: 0x0A,
    company: 'NEC',
    country: 'Japan',
  ),
  OkiElectricIndustry(
    id: 0x0B,
    company: 'Oki Electric Industry Co. Ltd',
    country: 'Japan',
  ),
  Toshiba(
    id: 0x0C,
    company: 'Toshiba Corp.',
    country: 'Japan',
  ),
  MitsubishiElectric(
    id: 0x0D,
    company: 'Mitsubishi Electric Corp.',
    country: 'Japan',
  ),
  SamsungElectronics(
    id: 0x0E,
    company: 'Samsung Electronics Co. Ltd',
    country: 'Korea',
  ),
  Hynix(
    id: 0x0F,
    company: 'Hynix',
    country: 'Korea',
  ),
  LGSemiconductors(
    id: 0x10,
    company: 'LG-Semiconductors Co. Ltd',
    country: 'Korea',
  ),
  EmosynEMMicroelectronics(
    id: 0x11,
    company: 'Emosyn-EM Microelectronics',
    country: 'USA',
  ),
  WisekeySemiconductors(
    id: 0x12,
    company: 'Wisekey Semiconductors',
    country: 'France',
  ),
  ORGAKartensysteme(
    id: 0x13,
    company: 'ORGA Kartensysteme GmbH',
    country: 'Germany',
  ),
  SHARP(
    id: 0x14,
    company: 'SHARP Corporation',
    country: 'Japan',
  ),
  ATMEL(
    id: 0x15,
    company: 'ATMEL',
    country: 'France',
  ),
  EMMicroelectronicMarin(
    id: 0x16,
    company: 'EM Microelectronic-Marin SA',
    country: 'Switzerland',
  ),
  SmartracTechnology(
    id: 0x17,
    company: 'SMARTRAC TECHNOLOGY GmbH',
    country: 'Germany',
  ),
  ZMD(
    id: 0x18,
    company: 'ZMD AG',
    country: 'Germany',
  ),
  XICOR(
    id: 0x19,
    company: 'XICOR, Inc.',
    country: 'USA',
  ),
  Sony(
    id: 0x1A,
    company: 'Sony Corporation',
    country: 'Japan',
  ),
  MalaysiaMicroelectronicSolutions(
    id: 0x1B,
    company: 'Malaysia Microelectronic Solutions Sdn. Bhd',
    country: 'Malaysia',
  ),
  Emosyn(
    id: 0x1C,
    company: 'Emosyn',
    country: 'USA',
  ),
  ShanghaiFudanMicroelectronics(
    id: 0x1D,
    company: 'Shanghai Fudan Microelectronics Co. Ltd.',
    country: 'P.R. China',
  ),
  MagellanTechnology(
    id: 0x1E,
    company: 'Magellan Technology Pty Limited',
    country: 'Australia',
  ),
  Melexis(
    id: 0x1F,
    company: 'Melexis NV',
    country: 'Switzerland',
  ),
  RenesasTechnology(
    id: 0x20,
    company: 'Renesas Technology Corp.',
    country: 'Japan',
  ),
  TAGSYS(
    id: 0x21,
    company: 'TAGSYS',
    country: 'France',
  ),
  Transcore(
    id: 0x22,
    company: 'Transcore',
    country: 'USA',
  ),
  ShanghaiBelling(
    id: 0x23,
    company: 'Shanghai belling corp., ltd.',
    country: 'China',
  ),
  MasktechGermany(
    id: 0x24,
    company: 'Masktech Germany Gmbh',
    country: 'Germany',
  ),
  InnovisionResearchTechnology(
    id: 0x25,
    company: 'Innovision Research and Technology Plc',
    country: 'UK',
  ),
  HitachiULSISystems(
    id: 0x26,
    company: 'Hitachi ULSI Systems Co., Ltd.',
    country: 'Japan',
  ),
  Yubico(
    id: 0x27,
    company: 'Yubico AB',
    country: 'Sweden',
  ),
  Ricoh(
    id: 0x28,
    company: 'Ricoh',
    country: 'Japan',
  ),
  ASK(
    id: 0x29,
    company: 'ASK',
    country: 'France',
  ),
  UnicoreMicrosystems(
    id: 0x2A,
    company: 'Unicore Microsystems, LLC',
    country: 'Russian Federation',
  ),
  DallasSemiconductorMaxim(
    id: 0x2B,
    company: 'Dallas Semiconductor/Maxim',
    country: 'USA',
  ),
  Impinj(
    id: 0x2C,
    company: 'Impinj, Inc.',
    country: 'USA',
  ),
  RightPlugAlliance(
    id: 0x2D,
    company: 'RightPlug Alliance',
    country: 'USA',
  ),
  Broadcom(
    id: 0x2E,
    company: 'Broadcom Corporation',
    country: 'USA',
  ),
  MStarSemiconductor(
    id: 0x2F,
    company: 'MStar Semiconductor, Inc',
    country: 'Taiwan, ROC',
  ),
  BeeDarTechnology(
    id: 0x30,
    company: 'BeeDar Technology Inc.',
    country: 'USA',
  ),
  RFIDsec(
    id: 0x31,
    company: 'RFIDsec',
    country: 'Denmark',
  ),
  SchweizerElectronic(
    id: 0x32,
    company: 'Schweizer Electronic AG',
    country: 'Germany',
  ),
  AMICTechnology(
    id: 0x33,
    company: 'AMIC Technology Corp',
    country: 'Taiwan',
  ),
  Mikron(
    id: 0x34,
    company: 'Mikron JSC',
    country: 'Russia',
  ),
  FraunhoferInstitutePhotonicMicrosystems(
    id: 0x35,
    company: 'Fraunhofer Institute for Photonic Microsystems',
    country: 'Germany',
  ),
  IDSMicrochip(
    id: 0x36,
    company: 'IDS Microchip AG',
    country: 'Switzerland',
  ),
  Kovio(
    id: 0x37,
    company: 'Kovio',
    country: 'USA',
  ),
  HMTMicroelectronic(
    id: 0x38,
    company: 'HMT Microelectronic Ltd',
    country: 'Switzerland',
  ),
  SiliconCraftTechnology(
    id: 0x39,
    company: 'Silicon Craft Technology',
    country: 'Thailand',
  ),
  AdvancedFilmDevice(
    id: 0x3A,
    company: 'Advanced Film Device Inc.',
    country: 'Japan',
  ),
  Nitecrest(
    id: 0x3B,
    company: 'Nitecrest Ltd',
    country: 'UK',
  ),
  Verayo(
    id: 0x3C,
    company: 'Verayo Inc.',
    country: 'USA',
  ),
  HIDGlobal(
    id: 0x3D,
    company: 'HID Global',
    country: 'USA',
  ),
  ProductivityEngineering(
    id: 0x3E,
    company: 'Productivity Engineering Gmbh',
    country: 'Germany',
  ),
  Austriamicrosystems(
    id: 0x3F,
    company: 'Austriamicrosystems AG',
    country: 'Austria',
  ),
  ThalesDIS(
    id: 0x40,
    company: 'Thales DIS',
    country: 'France',
  ),
  RenesasElectronics(
    id: 0x41,
    company: 'Renesas Electronics Corporation',
    country: 'Japan',
  ),
  Alogics(
    id: 0x42,
    company: '3Alogics Inc',
    country: 'Korea',
  ),
  TopTroniQAsia(
    id: 0x43,
    company: 'Top TroniQ Asia Limited',
    country: 'Hong Kong',
  ),
  Gentag(
    id: 0x44,
    company: 'Gentag Inc',
    country: 'USA',
  ),
  InvengoInformationTechnology(
    id: 0x45,
    company: 'Invengo Information Technology Co.Ltd',
    country: 'China',
  ),
  GuangzhouSysurMicroelectronics(
    id: 0x46,
    company: 'Guangzhou Sysur Microelectronics, Inc',
    country: 'China',
  ),
  CEITEC(
    id: 0x47,
    company: 'CEITEC S.A.',
    country: 'Brazil',
  ),
  ShanghaiQuanrayElectronics(
    id: 0x48,
    company: 'Shanghai Quanray Electronics Co. Ltd.',
    country: 'China',
  ),
  MediaTek(
    id: 0x49,
    company: 'MediaTek Inc',
    country: 'Taiwan',
  ),
  Angstrem(
    id: 0x4A,
    company: 'Angstrem PJSC',
    country: 'Russia',
  ),
  CelisicSemiconductor(
    id: 0x4B,
    company: 'Celisic Semiconductor (Hong Kong) Limited',
    country: 'China',
  ),
  LEGICIdentsystems(
    id: 0x4C,
    company: 'LEGIC Identsystems AG',
    country: 'Switzerland',
  ),
  Balluff(
    id: 0x4D,
    company: 'Balluff GmbH',
    country: 'Germany',
  ),
  OberthurTechnologies(
    id: 0x4E,
    company: 'Oberthur Technologies',
    country: 'France',
  ),
  SilterraMalaysia(
    id: 0x4F,
    company: 'Silterra Malaysia Sdn. Bhd.',
    country: 'Malaysia',
  ),
  DELTADanishElectronics(
    id: 0x50,
    company: 'DELTA Danish Electronics, Light & Acoustics',
    country: 'Denmark',
  ),
  GieseckeDevrient(
    id: 0x51,
    company: 'Giesecke & Devrient GmbH',
    country: 'Germany',
  ),
  ShenzhenChinaVisionMicroelectronics(
    id: 0x52,
    company: 'Shenzhen China Vision Microelectronics Co., Ltd.',
    country: 'China',
  ),
  ShanghaiFeijuMicroelectronics(
    id: 0x53,
    company: 'Shanghai Feiju Microelectronics Co. Ltd.',
    country: 'China',
  ),
  Intel(
    id: 0x54,
    company: 'Intel Corporation',
    country: 'USA',
  ),
  Microsensys(
    id: 0x55,
    company: 'Microsensys GmbH',
    country: 'Germany',
  ),
  SonixTechnology(
    id: 0x56,
    company: 'Sonix Technology Co., Ltd.',
    country: 'Taiwan',
  ),
  QualcommTechnologies(
    id: 0x57,
    company: 'Qualcomm Technologies Inc',
    country: 'USA',
  ),
  RealtekSemiconductor(
    id: 0x58,
    company: 'Realtek Semiconductor Corp',
    country: 'Taiwan',
  ),
  FreevisionTechnologies(
    id: 0x59,
    company: 'Freevision Technologies Co. Ltd',
    country: 'China',
  ),
  GiantecSemiconductor(
    id: 0x5A,
    company: 'Giantec Semiconductor Inc.',
    country: 'China',
  ),
  JSCAngstremT(
    id: 0x5B,
    company: 'JSC Angstrem-T',
    country: 'Russia',
  ),
  STARCHIP(
    id: 0x5C,
    company: 'STARCHIP',
    country: 'France',
  ),
  SPIRTECH(
    id: 0x5D,
    company: 'SPIRTECH',
    country: 'France',
  ),
  GANTNERElectronic(
    id: 0x5E,
    company: 'GANTNER Electronic GmbH',
    country: 'Austria',
  ),
  NordicSemiconductor(
    id: 0x5F,
    company: 'Nordic Semiconductor',
    country: 'Norway',
  ),
  Verisiti(
    id: 0x60,
    company: 'Verisiti Inc',
    country: 'USA',
  ),
  WearlinksTechnology(
    id: 0x61,
    company: 'Wearlinks Technology Inc.',
    country: 'China',
  ),
  UserstarInformationSystems(
    id: 0x62,
    company: 'Userstar Information Systems Co., Ltd',
    country: 'Taiwan',
  ),
  PragmaticPrinting(
    id: 0x63,
    company: 'Pragmatic Printing Ltd.',
    country: 'UK',
  ),
  AssociacaoDoLaboratorioDeSistemasIntegraveisTecnologico(
    id: 0x64,
    company:
        'Associação do Laboratório de Sistemas Integráveis Tecnológico – LSI-TEC',
    country: 'Brazil',
  ),
  Tendyron(
    id: 0x65,
    company: 'Tendyron Corporation',
    country: 'China',
  ),
  MUTOSmart(
    id: 0x66,
    company: 'MUTO Smart Co., Ltd.',
    country: 'Korea',
  ),
  ONSemiconductor(
    id: 0x67,
    company: 'ON Semiconductor',
    country: 'USA',
  ),
  TubitakBilgem(
    id: 0x68,
    company: 'TÜBİTAK BİLGEM',
    country: 'Turkey',
  ),
  HuadaSemiconductor(
    id: 0x69,
    company: 'Huada Semiconductor Co., Ltd',
    country: 'China',
  ),
  SEVENEY(
    id: 0x6A,
    company: 'SEVENEY',
    country: 'France',
  ),
  ThalesDISDesignServices(
    id: 0x6B,
    company: 'THALES DIS Design Services SAS',
    country: 'France',
  ),
  Wisesec(
    id: 0x6C,
    company: 'Wisesec Ltd',
    country: 'Israel',
  ),
  NMTeh(
    id: 0x6D,
    company: 'LTD "NM-Teh"',
    country: 'Russia',
  ),
  ifmElectronic(
    id: 0x70,
    company: 'ifm electronic gmbh',
    country: 'Germany',
  ),
  SichuanKilowayTechnologies(
    id: 0x71,
    company: 'Sichuan Kiloway Technologies Co., Ltd.',
    country: 'China',
  ),
  FordMotorCompany(
    id: 0x72,
    company: 'Ford Motor Company',
    country: 'US',
  ),
  BeijingTsingtengMicroSystem(
    id: 0x73,
    company: 'Beijing Tsingteng MicroSystem Co.,Ltd',
    country: 'China',
  ),
  HuadaEverCore(
    id: 0x74,
    company: 'Huada EverCore Co., Ltd',
    country: 'China',
  ),
  SmartchipMicroelectronics(
    id: 0x75,
    company: 'Smartchip Microelectronics Corporation',
    country: 'Taiwan',
  ),
  TongxinMicroelectronics(
    id: 0x76,
    company: 'Tongxin Microelectronics Co., Ltd.',
    country: 'China',
  ),
  NingboIOTMicroelectronics(
    id: 0x77,
    company: 'Ningbo IOT Microelectronics Co Ltd',
    country: 'China',
  ),
  AUOptronics(
    id: 0x78,
    company: 'AU Optronics',
    country: 'Taiwan',
  ),
  CUBIC(
    id: 0x79,
    company: 'CUBIC',
    country: 'USA',
  ),
  AbbottDiabetesCare(
    id: 0x7A,
    company: 'Abbott Diabetes Care',
    country: 'USA',
  ),
  ShenzenNationRFIDTechnology(
    id: 0x7B,
    company: 'Shenzen Nation RFID Technology Co Ltd',
    country: 'China',
  ),
  DBHiTek(
    id: 0x7C,
    company: 'DB HiTek Co Ltd',
    country: 'Korea',
  ),
  SATOVicinity(
    id: 0x7D,
    company: 'SATO Vicinity',
    country: 'Australia',
  ),
  Holtek(
    id: 0x7E,
    company: 'Holtek',
    country: 'Taiwan',
  ),
  ShenzhenGoodixTechnology(
    id: 0x7F,
    company: 'Shenzhen Goodix Technology Co., Ltd.',
    country: 'China',
  ),
  Panthronics(
    id: 0x80,
    company: 'Panthronics AG',
    country: 'Austria',
  ),
  BeijingHuadaInfosecTechnology(
    id: 0x81,
    company: 'Beijing Huada Infosec Technology Co., Ltd.',
    country: 'China',
  ),
  ShanghaiOrientalMagneticCardEngineering(
    id: 0x82,
    company: 'Shanghai Oriental Magnetic Card Engineering Co Ltd',
    country: 'China',
  ),
  ApeX(
    id: 0x83,
    company: '8ApeX Inc',
    country: 'US',
  ),
  Abbott(
    id: 0x84,
    company: 'Abbott',
    country: 'Ireland',
  ),
  Proqure(
    id: 0x85,
    company: 'Proqure Inc',
    country: 'US',
  ),
  SchreinerGroup(
    id: 0x86,
    company: 'Schreiner Group GmbH & Co. KG',
    country: 'Germany',
  ),
  ;

  const CardManufacturer({
    required this.id,
    required this.company,
    required this.country,
  });

  /// The ID of the card manufacturer.
  final int id;

  /// The name of the company that manufactures the card.
  final String company;

  /// The country where the card manufacturer is located.
  final String country;

  /// Returns the card manufacturer from the given manufacturer ID.
  factory CardManufacturer.fromInt(int id) {
    for (final manufacturer in CardManufacturer.values) {
      if (manufacturer.id == id) {
        return manufacturer;
      }
    }

    throw Exception('Invalid card manufacturer');
  }
}

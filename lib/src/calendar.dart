const _daysInMonth = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

int daysInMonth({required int years, required int month}) {
  // De schrikkeldag valt in de gregoriaanse kalender op 29 februari en komt voor als het jaartal restloos deelbaar is door 4,
  // maar niet door 100 – tenzij het jaartal restloos deelbaar door 400 is. Zo waren 2004, 2008, 2012 en 2016
  // (allemaal deelbaar door 4, maar niet door 100) schrikkeljaren. Ook 1600 (deelbaar door 400) was een schrikkeljaar.
  // 1700, 1800 en 1900 waren dat niet (deelbaar door 100, maar niet door 400) en 2000 weer wel.

  if (month == 2) {
    bool dividedByFour = years % 4 == 0;
    bool dividedByHundred = years % 100 == 0;
    bool dividedByFourHundred = years % 400 == 0;

    return _daysInMonth[month - 1] +
        ((dividedByFour && !dividedByHundred) || dividedByFourHundred ? 1 : 0);
  }

  return _daysInMonth[month - 1];
}

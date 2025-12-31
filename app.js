const timeElement = document.getElementById("time");
const statusElement = document.getElementById("status");

const nyFormatter = new Intl.DateTimeFormat("en-US", {
  timeZone: "America/New_York",
  hour: "2-digit",
  minute: "2-digit",
  second: "2-digit",
  hour12: false,
});

const nyPartsFormatter = new Intl.DateTimeFormat("en-US", {
  timeZone: "America/New_York",
  weekday: "short",
  hour: "2-digit",
  minute: "2-digit",
  second: "2-digit",
  hour12: false,
});

const marketOpen = { hour: 9, minute: 30 };
const marketClose = { hour: 16, minute: 0 };

const weekdayIndex = {
  Sun: 0,
  Mon: 1,
  Tue: 2,
  Wed: 3,
  Thu: 4,
  Fri: 5,
  Sat: 6,
};

const isMarketOpen = (date) => {
  const parts = nyPartsFormatter.formatToParts(date);
  const map = Object.fromEntries(parts.map((part) => [part.type, part.value]));
  const dayIndex = weekdayIndex[map.weekday];
  if (dayIndex === 0 || dayIndex === 6) {
    return false;
  }

  const hour = Number(map.hour);
  const minute = Number(map.minute);
  const totalMinutes = hour * 60 + minute;
  const openMinutes = marketOpen.hour * 60 + marketOpen.minute;
  const closeMinutes = marketClose.hour * 60 + marketClose.minute;

  return totalMinutes >= openMinutes && totalMinutes < closeMinutes;
};

const updateClock = () => {
  const now = new Date();
  const timeText = nyFormatter.format(now);
  timeElement.textContent = timeText;

  if (isMarketOpen(now)) {
    statusElement.textContent = "Open";
    statusElement.classList.add("widget__status--open");
    statusElement.classList.remove("widget__status--closed");
  } else {
    statusElement.textContent = "Closed";
    statusElement.classList.add("widget__status--closed");
    statusElement.classList.remove("widget__status--open");
  }
};

updateClock();
setInterval(updateClock, 1000);

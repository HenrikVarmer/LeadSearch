test_that("parse_google_title splits 'Name - Title - Workplace | LinkedIn'", {
  res <- parse_google_title("Jane Doe - Systems Engineer - Microsoft | LinkedIn")
  expect_equal(res$title, "Systems Engineer")
  expect_equal(res$workplace, "Microsoft")
})

test_that("parse_google_title handles en-dash separators", {
  res <- parse_google_title("Jane Doe – Astronaut – Space Agency")
  expect_equal(res$title, "Astronaut")
  expect_equal(res$workplace, "Space Agency")
})

test_that("parse_google_title returns 'error' for unparseable titles", {
  res <- parse_google_title("JaneDoeNoSeparators")
  expect_equal(res$title, "error")
  expect_equal(res$workplace, "error")

  res_empty <- parse_google_title("")
  expect_equal(res_empty$title, "error")
})

test_that("parse_bing_title splits dashed result titles", {
  res <- parse_bing_title("Jane Doe - Systems Engineer - Microsoft")
  expect_equal(res$title, "Systems Engineer")
  expect_equal(res$workplace, "Microsoft")
})

test_that("parse_bing_title strips a dashed lead name", {
  res <- parse_bing_title("Anne-Marie Doe - Lawyer - Acme", name = "Anne-Marie Doe")
  expect_equal(res$title, "Lawyer")
  expect_equal(res$workplace, "Acme")
})

test_that("parse_bing_title removes LinkedIn mentions", {
  res <- parse_bing_title("Jane Doe - Engineer LinkedIn - Acme LinkedIn")
  expect_equal(res$title, "Engineer")
  expect_equal(res$workplace, "Acme")
})

test_that("strip_linkedin is case-insensitive and trims", {
  expect_equal(strip_linkedin(" Acme LinkedIn "), "Acme")
  expect_equal(strip_linkedin("linkedin Corp"), "Corp")
})

test_that("no_result returns the expected sentinel vector", {
  nr <- no_result()
  expect_named(nr, c("title", "workplace", "link"))
  expect_true(all(nr == "No Result"))
})

test_that("extract_company returns the domain label", {
  expect_equal(extract_company("jane@acme.com"), "acme")
  expect_equal(extract_company("john.doe@sub.example.co.uk"), "sub")
  expect_equal(extract_company(""), "")
  expect_equal(extract_company(NA_character_), "")
})

test_that("extract_domain returns the full lower-cased domain", {
  expect_equal(extract_domain("jane@Acme.COM"), "acme.com")
  expect_equal(extract_domain("john@sub.example.co.uk"), "sub.example.co.uk")
  expect_equal(extract_domain(""), "")
  expect_equal(extract_domain(NA_character_), "")
})

test_that("is_free_mail flags free / empty addresses", {
  providers <- c("gmail.com", "hotmail.com", "yahoo.com")

  # Empty / missing addresses are treated as free (no company signal).
  expect_true(is_free_mail("", providers = providers))
  expect_true(is_free_mail(NA_character_, providers = providers))

  # Label-based detection (works even when the domain isn't in the file).
  expect_true(is_free_mail("jane@gmail.co.uk", providers = character(0)))
  expect_true(is_free_mail("jane@hotmail.com", providers = character(0)))

  # Full-domain detection via the provider list.
  expect_true(is_free_mail("jane@yahoo.com", providers = providers,
                          labels = character(0)))

  # Corporate addresses are not free.
  expect_false(is_free_mail("jane@acme.com", providers = providers))
})

test_that("free_mail_providers returns a character vector", {
  expect_type(free_mail_providers(), "character")
})

#define BOOST_TEST_MODULE BaseTest
#include <boost/test/unit_test.hpp>

BOOST_AUTO_TEST_CASE(TestAdd) {
    int i = 2;
    BOOST_TEST(i);
    BOOST_TEST(i == 2);
}

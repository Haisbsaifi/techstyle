
import pytest
import app as techstyle
from werkzeug.security import check_password_hash


@pytest.fixture
def client(tmp_path, monkeypatch):
    database = tmp_path / "techstyle_test.db"
    monkeypatch.setattr(techstyle, "DATABASE", str(database))

    techstyle.app.config["TESTING"] = True

    with techstyle.app.app_context():
        techstyle.init_db()
        db = techstyle.get_db()
        db.execute(
            """
            INSERT INTO products
            (name, description, price, category, stock)
            VALUES (?, ?, ?, ?, ?)
            """,
            ("Test Shirt", "Cotton shirt", 29.99, "shirts", 10),
        )
        db.execute(
            """
            INSERT INTO products
            (name, description, price, category, stock)
            VALUES (?, ?, ?, ?, ?)
            """,
            ("Test Shoes", "Running shoes", 79.99, "shoes", 5),
        )
        db.commit()

    with techstyle.app.test_client() as test_client:
        yield test_client


def test_home(client):
    response = client.get("/")
    assert response.status_code == 200


def test_product_search(client):
    response = client.get("/?search=Shirt")
    assert response.status_code == 200
    assert b"Test Shirt" in response.data


def test_product_category(client):
    response = client.get("/?category=shirts")
    assert response.status_code == 200
    assert b"Test Shirt" in response.data


def test_product_detail(client):
    response = client.get("/product/1")
    assert response.status_code == 200


def test_product_not_found(client):
    response = client.get("/product/9999")
    assert response.status_code == 302


def test_cart_empty(client):
    response = client.get("/cart")
    assert response.status_code == 200


def test_add_to_cart(client):
    response = client.post("/cart/add/1")
    assert response.status_code == 302

    with client.session_transaction() as session:
        assert session["cart"]["1"] == 1


def test_remove_from_cart(client):
    client.post("/cart/add/1")
    response = client.post("/cart/remove/1")

    assert response.status_code == 302

    with client.session_transaction() as session:
        assert "1" not in session["cart"]


def test_clear_cart(client):
    client.post("/cart/add/1")
    response = client.post("/cart/clear")

    assert response.status_code == 302

    with client.session_transaction() as session:
        assert session["cart"] == {}


def test_cart_count_api(client):
    client.post("/cart/add/1")

    response = client.get("/api/cart/count")
    assert response.status_code == 200
    assert response.get_json()["count"] == 1


def test_products_api(client):
    response = client.get("/api/products")

    assert response.status_code == 200
    products = response.get_json()
    assert len(products) == 2


def test_checkout_empty_cart(client):
    response = client.get("/checkout")
    assert response.status_code == 302


def test_checkout_success(client):
    client.post("/cart/add/1")

    response = client.post(
        "/checkout",
        data={
            "name": "Test Customer",
            "email": "test@example.com",
            "address": "Teststrasse 10",
        },
    )

    assert response.status_code == 302

    with techstyle.app.app_context():
        order = techstyle.query_db(
            "SELECT * FROM orders WHERE customer_email = ?",
            ("test@example.com",),
            one=True,
        )
        assert order is not None
        assert order["status"] == "confirmed"


def test_registration(client):
    response = client.post(
        "/register",
        data={
            "username": "newuser",
            "email": "new@example.com",
            "password": "SecureTestPassword123!",
        },
    )

    assert response.status_code == 302

    with techstyle.app.app_context():
        user = techstyle.query_db(
            "SELECT * FROM users WHERE username = ?",
            ("newuser",),
            one=True,
        )

        assert user is not None
        assert user["password"] != "SecureTestPassword123!"
        assert check_password_hash(
            user["password"], "SecureTestPassword123!"
        )


def test_login_success(client):
    client.post(
        "/register",
        data={
            "username": "loginuser",
            "email": "login@example.com",
            "password": "SecureTestPassword123!",
        },
    )

    response = client.post(
        "/login",
        data={
            "username": "loginuser",
            "password": "SecureTestPassword123!",
        },
    )

    assert response.status_code == 302

    with client.session_transaction() as session:
        assert session["username"] == "loginuser"


def test_login_invalid(client):
    response = client.post(
        "/login",
        data={
            "username": "unknown",
            "password": "wrongpassword",
        },
    )

    assert response.status_code == 200


def test_logout(client):
    response = client.get("/logout")
    assert response.status_code == 302

    with client.session_transaction() as session:
        assert "user_id" not in session


def test_about(client):
    response = client.get("/about")
    assert response.status_code == 200


def test_404(client):
    response = client.get("/not-existing-page")
    assert response.status_code == 404

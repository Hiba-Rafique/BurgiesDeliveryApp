package com.app.demo.models;

import jakarta.persistence.*;

import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "carts")
public class Cart {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    @OneToMany(mappedBy = "cart", cascade = CascadeType.ALL)
    private List<CartItem> cartItems;

    public Cart(){}
    public Cart(ArrayList<CartItem> cartItems) {}

    public List<CartItem> getCartItems() { return cartItems; }
    public void setCartItems(ArrayList<CartItem> cartItems) { this.cartItems = cartItems; }
}

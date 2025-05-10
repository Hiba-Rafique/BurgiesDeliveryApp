package com.app.demo.models;

import jakarta.persistence.*;

import java.util.ArrayList;

@Entity
@Table(name = "customers")
public class Customer extends User {
    private String phoneNum;
    private String address;

    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "cart_id")
    private Cart cart;

    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL)
    private ArrayList<Order> orders;

    public Customer(){}
    public Customer(String phoneNum, String address, String id) {}
    
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public Cart getCart() { return cart; }
    public void setCart(Cart cart) { this.cart = cart; }

    public ArrayList<Order> getOrders() { return orders; }
    public void setOrders(ArrayList<Order> orders) { this.orders = orders; }
}

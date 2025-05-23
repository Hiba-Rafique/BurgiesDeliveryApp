package com.app.demo.Controllers;

import com.app.demo.models.Cart;
import com.app.demo.models.Customer;
import com.app.demo.repository.CustomerRepository;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.Optional;

@RestController
@RequestMapping("/cart")
public class CartController {

    @Autowired
    private CustomerRepository customerRepository;

    @GetMapping("/{customerId}")
    public Cart getCartByCustomerId(@PathVariable Long customerId) {
        Optional<Customer> customerOpt = customerRepository.findById(customerId);
        if (customerOpt.isEmpty()) {
            throw new RuntimeException("Customer not found with ID " + customerId);
        }

        Customer customer = customerOpt.get();
        Cart cart = customer.getCart();

        if (cart == null) {
            throw new RuntimeException("Cart not found for customer with ID " + customerId);
        }

        return cart;
    }
}

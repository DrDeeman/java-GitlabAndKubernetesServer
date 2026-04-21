package app.db.entity;

import java.math.BigDecimal;
import java.time.LocalDate;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;


@Entity
@Table(schema = "public", name="products")
@Setter
@Getter
@AllArgsConstructor
@NoArgsConstructor
public class Products {
    
    @Id
    @Column(name="id", nullable=false, columnDefinition="serial")
    @GeneratedValue(strategy= GenerationType.SEQUENCE, generator="products_seq")
    @SequenceGenerator(name="products_seq", sequenceName="products_id_seq", allocationSize=10)
    private BigDecimal id;

    @Column(name="name")
    private String name;

    @Column(name="price", precision=20)
    private BigDecimal price;


    @Column(name="year_issue")
    private LocalDate year_issue;

    @Column(name="raiting")
    private double raiting;

    
}
